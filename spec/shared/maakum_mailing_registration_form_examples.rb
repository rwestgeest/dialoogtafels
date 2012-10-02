  shared_examples_for "a_maakum_mailing_registration_form" do 
    it "renders a mailing checkbox if the mailing system exists" do
      Tenant.any_instance.stub(:has_mailing? => true)
      do_get
      response.body.should have_selector("input[type='checkbox'][name='person[register_for_mailing]']")
    end
    it "renders no mailing checkbox if the mailing system does not exist" do
      Tenant.any_instance.stub(:has_mailing? => false)
      do_get
      response.body.should_not have_selector("input[type='checkbox'][name='person[register_for_mailing]']")
    end
  end

  shared_examples_for "a_mailing_registrar" do
    describe "when mailing parameter provided" do
      it "registers for mailing" do
        person_name = valid_attributes['name']
        person_email = valid_attributes['email']
        Tenant.any_instance.should_receive(:register_for_mailing).with(person_name, person_email)
        post :create, :person => valid_attributes.merge(:register_for_mailing => true)
      end
    end
  end

