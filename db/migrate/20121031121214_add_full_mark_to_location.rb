class AddFullMarkToLocation < ActiveRecord::Migration
  def up
    add_column :locations, :marked_full, :boolean, default: false
  end
  def down
    remove_column :locations, :marked_full
  end
end
