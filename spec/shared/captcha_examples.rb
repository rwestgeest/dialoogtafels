require 'captcha'
shared_examples_for "a_captcha_handler" do |model_name|
  let(:model_class) { model_name.to_s.camelize.constantize } 
  before do 
    Captcha.stub(:verified?).with(controller) { false }
    post :create, {model_name => valid_attributes }
  end

  it "renders new view" do
    response.should be_success
    response.should render_template(:new)
  end

  it "sets the flash message to the exception result" do
    response.body.should include(I18n.t('registration.captcha_error'))
  end

  it "assigns the organizer with the filled in values" do
    assigns(model_name).should be_a_new(model_class)
    valid_attributes.each do |key, value|
      assigns(model_name).send(key).should be(value, "#{key}")
    end
  end
end

