require 'spec_helper'

describe MailingMessage do
  ValidGroups = ['coordinators', 'organizers', 'conversation_leaders', 'participants']
  it { should validate_presence_of :reference }
  it { should validate_presence_of :groups } 
  ValidGroups.permutation.to_a.each do |value|
    it { should allow_value(value).for(:groups) }
  end
  (ValidGroups + ['bogus']).permutation.to_a.each do |value|
    it { should_not allow_value(value).for(:groups) }
  end
  
  it_should_behave_like 'a_scoped_object', :mailing_message

  it_should_behave_like "a_message" do
    def a_message(attributes = {})
      MailingMessage.new(attributes)
    end
  end

  describe "groups" do
    it "is one group if one is given" do
      MailingMessage.new(addressee_groups: 'coordinators').groups.should == ['coordinators']
    end
    it "is a list of groups if more separated by comma" do
      MailingMessage.new(addressee_groups: 'coordinators, organizers').groups.should == ['coordinators','organizers']
    end
  end
  describe "groups=" do
    it "assigns to addresse_groups" do
      message = MailingMessage.new
      message.groups=['coordinators', 'organizers']
      message.addressee_groups.should == 'coordinators, organizers'
    end
  end
end
