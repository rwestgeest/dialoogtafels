class CreateLocationComments < ActiveRecord::Migration
  def change
    create_table :location_comments do |t|
      t.text       :body
      t.string     :ancestry
      t.references :author
      t.references :location
      t.references :tenant
      t.timestamps
    end
    add_index :location_comments, :tenant_id
    add_index :location_comments, :author_id
    add_index :location_comments, :ancestry
  end
end
