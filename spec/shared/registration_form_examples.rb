shared_examples_for "a_registration_form_with_profile_fields" do
  it "does not render field by default" do
    profile_field = FactoryGirl.create :profile_field
    do_get
    response.body.should_not have_selector "input[name='person[#{profile_field.field_name_with_prefix}]']"
  end
  it "renders field that should be on form" do
    profile_field = FactoryGirl.create :profile_field, on_form: true
    do_get
    response.body.should have_selector "input[name='person[#{profile_field.field_name_with_prefix}]']"
  end
end

