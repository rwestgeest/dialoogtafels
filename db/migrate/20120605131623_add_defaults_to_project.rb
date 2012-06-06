class AddDefaultsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :conversation_length, :integer, :default => 180
    add_column :projects, :start_time, :datetime
    add_column :projects, :max_participants_per_table, :integer, :default => 8
  end
  Project.reset_column_information
  Project.all.each {|p| p.update_attributes :start_date => Date.today, :start_time => Time.now } 
end
