class CreateTrainings < ActiveRecord::Migration
  def change
    create_table "training_registrations", :force => true do |t|
      t.references :attendee
      t.references :training
      t.boolean "invited",     :default => false
      t.references :tenant
      t.timestamps
    end
    add_index :training_registrations, :tenant_id
    add_index :training_registrations, [:training_id, :attendee_id]

    create_table "trainings" do |t|
      t.datetime "start_time",         :null => false
      t.datetime "end_time",         :null => false
      t.integer  "max_participants",   :default => 20
      t.string   "name",               :default => "", :null => false
      t.text     "description",        :default => ""
      t.string   "location",           :default => "", :null => false
      t.integer  "participant_count",  :default => 0
      t.references :tenant
      t.references :project
      t.timestamps
    end
    add_index :trainings, [ :location, :start_time ]
    add_index :trainings, :tenant_id
    add_index :trainings, [:tenant_id, :project_id]
  end
end
