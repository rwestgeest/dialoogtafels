require 'spec_helper'

describe ProfileField do

  it { should validate_presence_of :field_name }
  it { should validate_presence_of :label } 

  describe "with tenant scope" do
    prepare_scope :tenant
    let!(:existing_field) { FactoryGirl.create :profile_string_field }
    it { should validate_uniqueness_of :field_name }  
    it { should validate_uniqueness_of :label }  
  end

  describe "field_name" do 
    describe "when changing label" do
      def a_field_with_label(label, attributes = {}) 
        field = ProfileField.new(attributes)
        field.label = label
        field
      end
      def and_field_name(field_name)
        {:field_name => field_name}
      end
      it "is undescored label if lowercase without spaces" do
        a_field_with_label('age').field_name.should == 'age'
        a_field_with_label('my age').field_name.should == 'my_age'
        a_field_with_label('My Age').field_name.should == 'my_age'
      end
      it "strips question_marks and other signs" do
        a_field_with_label('My! Age?<>.,/').field_name.should == 'my_age'
        a_field_with_label('My* Age?<>.,/').field_name.should == 'my_age'
        a_field_with_label('My#%@;: Age?<>.,/').field_name.should == 'my_age'
        a_field_with_label('My^&*(){}[]\ Age?<>.,/').field_name.should == 'my_age'
        a_field_with_label("My\"' Age").field_name.should == 'my_age'
        a_field_with_label('My Age?<>.,/').field_name.should == 'my_age'
      end
      it "ignores label wheb field name is given" do
        a_field_with_label('age', and_field_name('bla')).field_name.should == 'bla'
      end
      it "updates the field_name on update_attributes" do
        field = ProfileStringField.new
        field.update_attributes :label => 'Age'
        field.field_name.should == 'age'
      end
    end
  end
  describe "type_name" do
    it { ProfileField.new.type_name.should == 'profile_field.type.profile_field' }
    it { ProfileSelectionField.new.type_name.should == 'profile_field.type.profile_selection_field' }
    it { ProfileStringField.new.type_name.should == 'profile_field.type.profile_string_field' }
  end
end
