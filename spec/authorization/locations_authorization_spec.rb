require 'spec_helper'
RSpec::Matchers.define :authorize do |account| 
  chain :to_perform do |action|
    @action = action
  end
  match do |guard| 
    guard.authorized?(account, a_request_for(@action))
  end
  def a_request_for(path)
    request_params_for(path)
  end

  def request_params_for(path)
    path, parameters = path.split("?")
    controller, action = path.split('#')
    parameters_hash = Hash[ parameters &&  parameters.split("&").map {|key_value| key_value.split('=').map{|e| e.strip }} || [] ]
    parameters_hash['controller'] = controller
    parameters_hash['action'] = action || 'index'
    parameters_hash
  end
end

describe ActionGuard do
  prepare_scope :tenant
  subject { load_action_guard_from File.join(Rails.root, 'config', 'authorization.rules') }

  let(:maintainer) { FactoryGirl.create :maintainer_account } 
  let(:coordinator) { FactoryGirl.create :coordinator_account } 
  let(:organizer) { FactoryGirl.create(:organizer).account } 
  let(:participant) { FactoryGirl.create(:participant).account }
  let(:conversation_leader) { FactoryGirl.create(:conversation_leader).account }

  it { should authorize(maintainer).to_perform("admin") }
  it { should_not authorize(coordinator).to_perform("admin") }

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

  it { should authorize(organizer).to_perform("organizer/locations") }
  it { should_not authorize(coordinator).to_perform("organizer/locations") }
  it { should_not authorize(maintainer).to_perform("organizer/locations") }
  it { should_not authorize(conversation_leader).to_perform("organizer/locations") }
  it { should_not authorize(participant).to_perform("organizer/locations") }

  it { should authorize(maintainer).to_perform("conversations") }
  it { should authorize(organizer).to_perform("conversations") }
  it { should authorize(coordinator).to_perform("conversations") }
  it { should_not authorize(conversation_leader).to_perform("conversations") }
  it { should_not authorize(participant).to_perform("conversations") }

  it { should authorize(maintainer).to_perform("city/publications") }
  it { should authorize(organizer).to_perform("city/publications") }
  it { should authorize(coordinator).to_perform("city/publications") }
  it { should_not authorize(conversation_leader).to_perform("city/publications") }
  it { should_not authorize(participant).to_perform("city/publications") }

  it { should authorize(conversation_leader).to_perform("contributor/registration")  }
  it { should authorize(participant).to_perform("contributor/registration")  }

  it { should_not authorize(maintainer).to_perform("contributor/registration") } 
  it { should_not authorize(coordinator).to_perform("contributor/registration") } 
  it { should_not authorize(organizer).to_perform("contributor/registration") } 

  it { should authorize(conversation_leader).to_perform("contributor/profile") }
  it { should authorize(participant).to_perform("contributor/profile") }
  it { should_not authorize(maintainer).to_perform("contributor/profile") } 
  it { should authorize(coordinator).to_perform("contributor/profile") } 
  it { should authorize(organizer).to_perform("contributor/profile") } 

  it { should authorize(participant).to_perform("accounts/password") }
  it { should_not authorize(nil).to_perform("accounts/password") }

  def load_action_guard_from file_path
    guard = ActionGuard::Guard.new 
    guard.load_from_string(File.read(file_path), file_path)
    guard.stub :inspect => 'action_guard'
    guard
  end
end

