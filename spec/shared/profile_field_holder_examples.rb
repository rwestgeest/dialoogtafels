shared_examples_for "a_profile_field_holder" do
  describe "profile value" do
    let!(:age_field) { FactoryGirl.create :profile_string_field, :field_name => 'age' }

    describe "setting through mass assignment" do 
      it "adds a profile value instance for the profile field" do
        expect { subject.update_attributes :profile_age => "66" }.to change(ProfileFieldValue, :count).by(1)
      end
      it "ignores value of nil" do
        expect { subject.update_attributes :profile_age => nil }.not_to change(ProfileFieldValue, :count)
      end
      it "ignores value of empty" do
        expect { subject.update_attributes :profile_age => "" }.not_to change(ProfileFieldValue, :count)
      end
      context "when field is not available" do
        it "raises a rails compatible error" do
          expect { subject.update_attributes :profile_country => "Kuwait" }.to raise_exception ActiveRecord::UnknownAttributeError
        end
      end 
      context "when value exists" do
        before {subject.update_attributes :profile_age => "55"} 
        it "removes the field value when set to empty" do
          expect { subject.update_attributes :profile_age => "" }.to change(ProfileFieldValue, :count).by(-1)
        end
        it "removes the field value when set to nil" do
          expect { subject.update_attributes :profile_age => nil }.to change(ProfileFieldValue, :count).by(-1)
        end
        it "does not change the number of values when changed" do
          expect { subject.update_attributes :profile_age => "66" }.not_to change(ProfileFieldValue, :count)
          subject.profile_age.should == "66"
        end
      end
    end

    describe "setting at creation" do
      let(:klass) { subject.class }
      let(:object_name) { subject.class.to_s.underscore } 

      it "creates an instance" do
        begin
        expect{ FactoryGirl.create object_name, :profile_age => "55" }.to change(klass, :count).by(1)
        rescue ActiveRecord::RecordInvalid => e 
          p e.record.errors.full_messages
          puts e.backtrace.join($/)
          raise e 
        end
      end

    end

    describe "getting" do
      it "returns the value when set" do
        subject.update_attributes :profile_age => "66"
        subject.profile_age.should == "66"
      end
      it "returns nil when not set" do
        subject.profile_age.should be_nil
      end
      context "when field is not available" do
        it "raisses a rails compatible error" do
          expect { subject.profile_country }.to raise_exception NoMethodError
        end
      end 
      context "before type case" do
        it "returns the value when set" do
          subject.update_attributes :profile_age => "66"
          subject.profile_age_before_type_cast.should == "66"
        end
        it "returns nil when not set" do
          subject.profile_age_before_type_cast.should be_nil
        end
      end
    end
  end
end

