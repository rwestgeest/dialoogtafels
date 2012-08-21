class ProfileField < ActiveRecord::Base
  attr_accessible :label, :type, :values, :field_name, :on_form
  include ScopedModel
  scope_to_tenant

  validates :field_name, :presence => :true, :uniqueness => true
  validates :label, :presence => :true, :uniqueness => true

  scope :on_form, where(:on_form => true)

  def self.selection_options
    [['tekst regel', 'ProfileStringField'], 
     ['tekst blok', 'ProfileTextField'],
     ['selectielijst', 'ProfileSelectionField']]
  end

  def label=(new_label)
    super
    return if !label || field_name && !field_name.empty?
    self.field_name = label.gsub(' ', '_').gsub(/[!?<>\.,\/\*\-@%;:#\^&\(\)\{\}\[\]\\"']/, '').underscore 
  end
  def field_name_with_prefix
    'profile_' + field_name
  end
  def render_field_on(form, options = {})
    form.text_field field_name_with_prefix, options
  end
  def type_name
    @type_name ||= 'profile_field.type.' + self.class.to_s.underscore
  end
end
