class AddGroupingStrategyToProject < ActiveRecord::Migration
  def change
    add_column :projects, :grouping_strategy, :string, :default => 'none', :null => false
  end
end
