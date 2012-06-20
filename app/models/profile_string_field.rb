class ProfileStringField < ProfileField
  include ScopedModel
  scope_to_tenant
  def render_field_on(form, options = {})
    form.text_field field_name_with_prefix, options
  end
end
