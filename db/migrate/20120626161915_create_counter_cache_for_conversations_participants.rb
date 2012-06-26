class CreateCounterCacheForConversationsParticipants < ActiveRecord::Migration
  def change
    add_column :conversations, :participant_count, :integer, :default => 0
    add_column :conversations, :conversation_leader_count, :integer, :default => 0
    Conversation.reset_column_information
    Conversation.all.each do |c|
      Conversation.update_counters c.id, :participant_count => c.participants.length
      Conversation.update_counters c.id, :conversation_leader_count => c.conversation_leaders.length
    end
  end
end
