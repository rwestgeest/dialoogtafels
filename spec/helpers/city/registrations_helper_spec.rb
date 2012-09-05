require 'spec_helper'
describe City::RegistrationsHelper do
  include City::RegistrationsHelper
    describe "people_filters_for_select" do
      it "has all filters" do
        people_filters_for_select.should == [
          ['Alle', 'all'],
          ['Tafelorganisatoren', 'organizers'],
          ['Deelnemers', 'participants'],
          ['Gespreksleiders', 'conversation_leaders'],
          ['Niet ingedeelde deelnemers', 'free_participants'],
          ['Niet ingedeelde gespreksleiders', 'free_conversation_leaders']
        ]
      end
    end
end
