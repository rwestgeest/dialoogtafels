class ProfileTextField < ProfileField
  include ScopedModel
  scope_to_tenant
  def render_field_on(form, options = {})
    form.text_area field_name_with_prefix, { :rows => 5, :class => 'profile_text_area' }.merge(options)
  end
end
