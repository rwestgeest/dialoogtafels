require 'spec_helper'

describe ActionGuard, :type => :authorisation do
  prepare_scope :tenant
  subject { load_action_guard_from File.join(Rails.root, 'config', 'authorization.rules') }

  let(:maintainer) { FactoryGirl.create :maintainer_account } 
  let(:coordinator) { FactoryGirl.create :coordinator_account } 
  let(:organizer) { FactoryGirl.create(:organizer).account } 
  let(:participant) { FactoryGirl.create(:participant).account }
  let(:conversation_leader) { FactoryGirl.create(:conversation_leader).account }

  def account_for role
    self.send role
  end

  describe "admin" do
    it { should authorize(maintainer).to_perform("admin") }
    it { should_not authorize(coordinator).to_perform("admin") }
  end

  describe "city/trainings" do
    it { should authorize(coordinator).to_perform("city/trainings")  }
    it { should_not authorize(organizer).to_perform("city/trainings")  }
  end

  describe "city/locations" do
    it { should authorize(coordinator).to_perform("city/locations#index")  }
    it { should authorize(coordinator).to_perform("city/locations#new")  }
    it { should authorize(coordinator).to_perform("city/locations#create")  }

    it { should_not authorize(organizer).to_perform("city/locations#index")  }
    it { should_not authorize(organizer).to_perform("city/locations#new")  }
    it { should_not authorize(organizer).to_perform("city/locations#create")  }

    it { should authorize(maintainer).to_perform("city/locations/projects")  }
    it { should authorize(coordinator).to_perform("city/locations/projects")  }
    it { should_not authorize(organizer).to_perform("city/locations/projects")  }
    it { should_not authorize(participant).to_perform("city/locations/projects")  }
    it { should_not authorize(conversation_leader).to_perform("city/locations/projects")  }

    it { should authorize(organizer).to_perform("city/locations#edit")  }
    it { should authorize(organizer).to_perform("city/locations#update")  }

    it { should_not authorize(conversation_leader).to_perform("city/locations#index")  }
    it { should_not authorize(conversation_leader).to_perform("city/locations#edit")  }
    it { should_not authorize(conversation_leader).to_perform("city/locations#update")  }
  end

  describe "city/training_registrations" do
    %w{maintainer coordinator}.each do |role|  
      it { should authorize(account_for(role)).to_perform("city/training_registrations") } 
    end
    %w{conversation_leader organizer participant}.each do |role|  
      it { should_not authorize(account_for(role)).to_perform("city/training_registrations") } 
    end
  end

  describe "city/registrations" do
    %w{maintainer coordinator}.each do |role|  
      it { should authorize(account_for(role)).to_perform("city/registrations") } 
    end
    %w{conversation_leader organizer participant}.each do |role|  
      it { should_not authorize(account_for(role)).to_perform("city/registrations") } 
    end
  end

  describe "organizer/locations" do
    it { should authorize(organizer).to_perform("organizer/locations") }
    it { should_not authorize(coordinator).to_perform("organizer/locations") }
    it { should_not authorize(maintainer).to_perform("organizer/locations") }
    it { should_not authorize(conversation_leader).to_perform("organizer/locations") }
    it { should_not authorize(participant).to_perform("organizer/locations") }
  end

  describe "conversations" do
    it { should authorize(maintainer).to_perform("conversations") }
    it { should authorize(organizer).to_perform("conversations") }
    it { should authorize(coordinator).to_perform("conversations") }
    it { should_not authorize(conversation_leader).to_perform("conversations") }
    it { should_not authorize(participant).to_perform("conversations") }
  end

  describe "city/publications" do
    it { should authorize(maintainer).to_perform("city/publications") }
    it { should authorize(organizer).to_perform("city/publications") }
    it { should authorize(coordinator).to_perform("city/publications") }
    it { should_not authorize(conversation_leader).to_perform("city/publications") }
    it { should_not authorize(participant).to_perform("city/publications") }
  end

  describe "contributor/registration" do
    it { should authorize(conversation_leader).to_perform("contributor/registration")  }
    it { should authorize(participant).to_perform("contributor/registration")  }

    it { should_not authorize(maintainer).to_perform("contributor/registration") } 
    it { should_not authorize(coordinator).to_perform("contributor/registration") } 
    it { should_not authorize(organizer).to_perform("contributor/registration") } 
  end
  
  describe "contributor/training_registrations" do
    it { should authorize(conversation_leader).to_perform("contributor/training_registrations")  }
    %w{maintainer coordinator organizer participant}.each do |role|
      it { should_not authorize(account_for(role)).to_perform("contributor/training_registrations")  }
    end
  end

  describe "contributor/profile" do
    it { should authorize(conversation_leader).to_perform("contributor/profile") }
    it { should authorize(participant).to_perform("contributor/profile") }
    it { should_not authorize(maintainer).to_perform("contributor/profile") } 
    it { should authorize(coordinator).to_perform("contributor/profile") } 
    it { should authorize(organizer).to_perform("contributor/profile") } 
  end

  describe "accounts/password" do
    it { should authorize(participant).to_perform("accounts/password") }
    it { should_not authorize(nil).to_perform("accounts/password") }
  end
end

