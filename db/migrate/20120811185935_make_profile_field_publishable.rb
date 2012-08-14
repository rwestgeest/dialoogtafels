class MakeProfileFieldPublishable < ActiveRecord::Migration
  def change
    add_column :profile_fields, :on_form, :boolean, default:false
    add_index :profile_fields, :on_form
  end
end
