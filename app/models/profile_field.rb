class ProfileField < ActiveRecord::Base
  attr_accessible :label, :type, :values, :field_name
  include ScopedModel
  scope_to_tenant

  validates :field_name, :presence => :true, :uniqueness => true
  validates :label, :presence => :true, :uniqueness => true

  def initialize(*args)
    super
    self.field_name = label.gsub(' ', '_').gsub(/[!?<>\.,\/\*\-@%;:#\^&\(\)\{\}\[\]\\"']/, '').underscore  unless field_name && !field_name.empty?
  end
  def field_name_with_prefix
    'profile_' + field_name
  end
  def render_field_on(form)
    form.text_field field_name_with_prefix
  end
end
