class Person < ActiveRecord::Base
  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  include ScopedModel
  scope_to_tenant
  has_one :account
  has_many :contributors
  has_many :profile_field_values, :include => :profile_field

  validates :email, :format => EMAIL_REGEXP, :if => :email_present?
  validates :name, :presence => true
  validates :telephone, :presence => true

  attr_protected :tenant_id

  delegate :email, :to => :account, :allow_nil => true

  def email=(email)
    self.account = TenantAccount.contributor(self) unless account
    self.account.email = email
  end

  def set_profile_attribute(attribute, value)
    return profile_field_value_for(attribute).destroy if value.nil? || value.empty?
    return profile_field_value_for(attribute).update_attribute :value, value if profile_field_values.where('profile_fields.field_name' => attribute).exists?
    profile_field_values << ProfileFieldValue.create(:value => value,
                             :profile_field => ProfileField.find_by_field_name(attribute))
  end

  def get_profile_attribute(attribute)
    profile_field_value_for(attribute).value
  end
  
  def active_contributions_for(project)
    # contributors.where('contributors.project_id' => project.id)
     contributors.for_project(project.id) 
  end

  def attribute_method?(attr_name)
    super || (attr_name.to_s =~ /^profile_(.*)$/ && profile_field_exists?($1))
  end

  def method_missing(method, *args)
    method = method.to_s
    return super unless method =~ /^profile_(.*?)(=|_before_type_cast)?$/ 
    raise NoMethodError.new(method) unless profile_field_exists?($1)
    return self.set_profile_attribute($1, *args) if method =~ /^profile_(.*)=/ 
    return self.get_profile_attribute($1) if method =~ /^profile_(.*)_before_type_cast/ 
    return self.get_profile_attribute($1) if method =~ /^profile_(.*)/ 
  end

  def profile_field_for(profile_field)
    'profile_' + profile_field.label
  end
  private 

  def email_present?
    email && !email.empty?
  end

  def profile_field_exists?(field)
    ProfileField.find_by_field_name(field)
  end

  def profile_field_value_for(attribute)
    profile_field_values.where('profile_fields.field_name' => attribute).first || ProfileFieldValue.null
  end
end
