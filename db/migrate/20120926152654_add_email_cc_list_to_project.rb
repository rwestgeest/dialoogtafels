class AddEmailCcListToProject < ActiveRecord::Migration
  def change
    add_column :projects, :cc_address_list, :string
    add_column :projects, :cc_type, :string, :null => false, :length => 10, :default => "none"
  end

end
