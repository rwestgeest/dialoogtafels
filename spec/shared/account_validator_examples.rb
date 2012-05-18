  shared_examples_for "an_account_validator" do
    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should allow_value("some@mail.nl").for(:email) }
    it { should allow_value("email@domaindiscount24.com").for(:email) }

    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end

    it { should validate_presence_of :role } 

    describe "on password" do 
      it "accepts no password on create" do
        account.should be_persisted
      end
      it "requires password on save" do
        account.save.should be_false
        account.errors_on(:password).should_not be_empty
      end
    end
  end

