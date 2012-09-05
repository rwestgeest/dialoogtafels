require 'spec_helper'

describe ConversationLeaderAmbition do
  it { should validate_presence_of :person }

  prepare_scope :tenant
  describe "creating" do
    let(:person) { FactoryGirl.create :person }

    it "creates an instance" do
      expect { ConversationLeaderAmbition.create person: person }.to change(ConversationLeaderAmbition, :count).by(1)
    end
    it "for different people creates more instances" do
      expect { 
        ConversationLeaderAmbition.create person: person 
        ConversationLeaderAmbition.create person: FactoryGirl.create(:person) 
      }.to change(ConversationLeaderAmbition, :count).by(2)
    end
    it "creates it only once for one person if tried twice" do
      expect { 
        ConversationLeaderAmbition.create person: person 
        ConversationLeaderAmbition.create person: person 
      }.to change(ConversationLeaderAmbition, :count).by(1)
    end
    it "for different projects creates more instances" do
      expect { 
        ConversationLeaderAmbition.create person: person 
        ambition_for_other_project = ConversationLeaderAmbition.new person: person
        ambition_for_other_project.project = FactoryGirl.create(:project)
        ambition_for_other_project.save
      }.to change(ConversationLeaderAmbition, :count).by(2)
    end
  end
end
