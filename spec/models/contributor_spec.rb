require 'spec_helper'

describe  Contributor do
  describe 'type_name' do
    it { Organizer.new.type_name.should == 'contributor.type.organizer' }
    it { ConversationLeader.new.type_name.should == 'contributor.type.conversation_leader' }
    it { Participant.new.type_name.should == 'contributor.type.participant' }
  end

end

