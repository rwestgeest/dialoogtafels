shared_examples_for "a_registration_form_with_profile_fields" do
  it "fields are rendered" do
    profile_field = FactoryGirl.create :profile_field
    do_get
    response.body.should have_selector "input[name='person[#{profile_field.field_name_with_prefix}]']"
  end
end

