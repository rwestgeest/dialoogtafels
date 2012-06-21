class ProfileSelectionField < ProfileField
  attr_accessible :values
  include ScopedModel
  scope_to_tenant
  validates_presence_of :values
  def render_field_on(form, options = {})
    form.select field_name_with_prefix, selection_options, options, :class => 'normal'
  end
  def selection_options
    values.split($/).map{|value| value.strip}.map {|value| [value, value]}
  end
end
