require 'spec_helper'

describe ProfileSelectionField do
  it_should_behave_like 'a_scoped_object', :profile_selection_field
  it { should validate_presence_of :label }
  it { should validate_presence_of :values }

  describe "selection_options" do
    def for_values(values)
      ProfileSelectionField.new(:values => values)
    end
    it { for_values("val1").selection_options.should == [['val1', 'val1']] } 
    it { for_values("val1\nval2").selection_options.should == [['val1', 'val1'],['val2','val2']] } 
    it { for_values("val1\r\nval2").selection_options.should == [['val1', 'val1'],['val2','val2']] } 
  end
end

