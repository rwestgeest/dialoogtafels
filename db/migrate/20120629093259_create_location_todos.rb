class CreateLocationTodos < ActiveRecord::Migration
  def change 
    create_table :location_todos do |t|
      t.string :name, :limit => 100
      t.integer :project_id
      t.references :tenant
      t.timestamps
    end
    add_index :location_todos, :project_id
    add_index :location_todos, :name

    create_table :finished_location_todos do |t|
      t.integer :location_todo_id
      t.integer :location_id
      t.references :tenant
      t.timestamps
    end
    add_index :finished_location_todos, :location_todo_id
    add_index :finished_location_todos, :location_id

  end
end
