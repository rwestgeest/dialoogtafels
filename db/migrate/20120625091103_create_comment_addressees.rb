class CreateCommentAddressees < ActiveRecord::Migration
  def change
    create_table :comment_addressees do |t|
      t.references :location_comment
      t.references :person
      t.timestamps
    end
    add_index :comment_addressees, :location_comment_id
    add_index :comment_addressees, :person_id
  end
end
