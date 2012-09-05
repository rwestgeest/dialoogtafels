require 'spec_helper'

describe ParticipantAmbition do
  it { should validate_presence_of :person }

  prepare_scope :tenant
  describe "creating" do
    let(:person) { FactoryGirl.create :person }

    it "creates an instance" do
      expect { ParticipantAmbition.create person: person }.to change(ParticipantAmbition, :count).by(1)
    end
    it "for different people creates more instances" do
      expect { 
        ParticipantAmbition.create person: person 
        ParticipantAmbition.create person: FactoryGirl.create(:person) 
      }.to change(ParticipantAmbition, :count).by(2)
    end
    it "creates it only once for one person if tried twice" do
      expect { 
        ParticipantAmbition.create person: person 
        ParticipantAmbition.create person: person 
      }.to change(ParticipantAmbition, :count).by(1)
    end
  end
end

