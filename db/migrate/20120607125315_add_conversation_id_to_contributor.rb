class AddConversationIdToContributor < ActiveRecord::Migration
  def change
    add_column 'contributors', "conversation_id", :integer
    add_index "contributors", "project_id"
    add_index "contributors", "conversation_id"
    add_index "conversations", "location_id"
  end
end
