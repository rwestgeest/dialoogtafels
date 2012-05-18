class AddResetDateToAccount < ActiveRecord::Migration
  def change
    add_column :accounts, :reset_at, :datetime, :default => nil
  end
end
