require 'spec_helper'

describe Person do
  it_should_behave_like 'a_scoped_object', :person

  describe "validations" do
    prepare_scope :tenant
    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end
    it {should validate_presence_of :telephone }
    it {should validate_presence_of :name }
  end

  context "with current tenant" do 
    prepare_scope :tenant

    describe "creating a person" do 
      it "creates an account if email address is supplied" do
        expect{ FactoryGirl.create :person }.to change(Account, :count).by(1)
        Account.last.person.should === Person.last
      end
      it "creates no account if email addres is not supplied" do
        expect{ FactoryGirl.create :person, :email => nil }.to change(Person, :count).by(1)
        expect{ FactoryGirl.create :person, :email => nil }.not_to change(Account, :count).by(1)
      end
    end
  end
end
