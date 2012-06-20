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

    describe "profile value" do
      let!(:age_field) { FactoryGirl.create :profile_string_field, :field_name => 'age' }
      let(:person) { FactoryGirl.create :person }
     
      describe "setting through mass assignment" do 
        it "adds a profile value instance for the profile field" do
          expect { person.update_attributes :profile_age => "66" }.to change(ProfileFieldValue, :count).by(1)
        end
        it "ignores value of nil" do
          expect { person.update_attributes :profile_age => nil }.not_to change(ProfileFieldValue, :count)
        end
        it "ignores value of empty" do
          expect { person.update_attributes :profile_age => "" }.not_to change(ProfileFieldValue, :count)
        end
        context "when field is not available" do
          it "raises a rails compatible error" do
            expect { person.update_attributes :profile_country => "Kuwait" }.to raise_exception ActiveRecord::UnknownAttributeError
          end
        end 
        context "when value exists" do
          before {person.update_attributes :profile_age => "55"} 
          it "removes the field value when set to empty" do
            expect { person.update_attributes :profile_age => "" }.to change(ProfileFieldValue, :count).by(-1)
          end
          it "removes the field value when set to nil" do
            expect { person.update_attributes :profile_age => nil }.to change(ProfileFieldValue, :count).by(-1)
          end
          it "does not change the number of values when changed" do
            expect { person.update_attributes :profile_age => "66" }.not_to change(ProfileFieldValue, :count)
            person.profile_age.should == "66"
          end
        end
      end

      describe "getting" do
        it "returns the value when set" do
          person.update_attributes :profile_age => "66"
          person.profile_age.should == "66"
        end
        it "returns nil when not set" do
          person.profile_age.should be_nil
        end
        context "when field is not available" do
          it "raisses a rails compatible error" do
            expect { person.profile_country }.to raise_exception NoMethodError
          end
        end 
        context "before type case" do
          it "returns the value when set" do
            person.update_attributes :profile_age => "66"
            person.profile_age_before_type_cast.should == "66"
          end
          it "returns nil when not set" do
            person.profile_age_before_type_cast.should be_nil
          end
        end
      end
    end
  end


end
