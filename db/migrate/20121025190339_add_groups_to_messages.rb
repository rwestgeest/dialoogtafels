class AddGroupsToMessages < ActiveRecord::Migration
  def change
    change_table :messages do |t|
      t.string :addressee_groups, :default => ""
    end
  end
end
