
##
# adds profile fields to person
# utilizes method missing and attribute_method? to detect that a profile field is being obtained or changed
# 
module ProfileFields
  def set_profile_attribute(attribute, value)
    return profile_field_value_for(attribute).destroy if value.nil? || value.empty?
    return profile_field_value_for(attribute).update_attribute :value, value if profile_field_values.where('profile_fields.field_name' => attribute).exists?
    profile_field_values << ProfileFieldValue.create(:value => value,
                             :profile_field => ProfileField.find_by_field_name(attribute))
  end

  def get_profile_attribute(attribute)
    profile_field_value_for(attribute).value
  end
  
  def conversation_contributions_for(project)
    # contributors.where('contributors.project_id' => project.id)
     contributors.for_project(project.id).where("contributors.type <> 'Organizer'") 
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

  def profile_field_exists?(field)
    ProfileField.find_by_field_name(field)
  end

  def profile_field_value_for(attribute)
    profile_field_values.where('profile_fields.field_name' => attribute).first || ProfileFieldValue.null
  end
end

class Person < ActiveRecord::Base
  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  include ScopedModel
  include ProfileFields

  scope_to_tenant
  has_one :account
  has_many :contributors
  has_many :participants
  has_many :conversation_leaders
  has_many :training_registrations, :foreign_key => :attendee_id, :include => :training, :dependent => :destroy, :autosave => true
  has_many :trainings, :through => :training_registrations
  has_many :profile_field_values, include: :profile_field, inverse_of: :person, autosave: true
  has_many :conversations_participating_in_as_leader, through: :conversation_leaders, source: :conversation
  has_many :conversations_participating_in_as_participant, through: :participants, source: :conversation
  has_many :conversations_participating_in, through: :contributors, source: :conversation

  validates :email, :format => EMAIL_REGEXP, :if => :email_present?
  validates :name, :presence => true
  validates :telephone, :presence => true

  attr_protected :tenant_id

  delegate :email, :to => :account, :allow_nil => true

  scope :conversation_leaders_for, lambda{|project| includes(:conversation_leaders).where('contributors.project_id' => project.id) }

  def self.find_by_email email
    includes(:account).where('accounts.email' => email).first
  end

  def replace_training_registrations(training_ids)
    training_registrations.destroy_all
    training_ids.each {|training_id| register_for(training_id) }
  end

  def register_for training
    begin 
      return register_for Training.find(training) unless training.is_a? Training
      trainings << training
      return training
    rescue ActiveRecord::RecordInvalid => e
      return nil
    rescue ActiveRecord::RecordNotFound => e
      return nil
    end
  end

  def registered_for_training?(training_id)
    !training_registrations.select { |training_registration| training_registration.training_id == training_id.to_i }.empty?
  end

  def cancel_registration_for training
    begin 
      training = trainings.find(training)
      trainings.delete training
      return training
    rescue ActiveRecord::RecordNotFound
      return nil
    end
  end

  def conversations_participating_in
    conversations_participating_in_as_leader + conversations_participating_in_as_participant
  end

  def highest_contribution(project)
    contributors.for_project(project).sort { |x,y| x.ordinal_value <=> y.ordinal_value }.first
  end

  def email=(email)
    self.account = TenantAccount.contributor(self) unless account
    self.account.email = email
  end

  private 
  def email_present?
    email && !email.empty?
  end

end
