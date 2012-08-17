class SplitTrainingTypeFromTraining < ActiveRecord::Migration
  class TrainingType < ActiveRecord::Base
    attr_accessible :name, :description, :project_id, :tenant_id

  end
  class Training < ActiveRecord::Base
    attr_accessible :name, :description, :project_id, :tenant_id
    belongs_to :training_type
  end

  def up
    create_table :training_types do |t|
      t.string   "name",              :default => "", :null => false
      t.text     "description",       :default => ""
      t.references :project
      t.references :tenant
      t.timestamps
    end
    add_index :training_types, :project_id
    add_index :training_types, :tenant_id 

    add_column :trainings, :training_type_id, :integer
    add_index :trainings, :training_type_id

    Training.unscoped do 
      Training.all.each do |training| 
        training.create_training_type! name: training.name, description: training.description, :tenant_id => training.tenant_id, :project_id => training.project_id
        training.save!
      end
    end

    remove_column :trainings, :name
    remove_column :trainings, :description
    remove_column :trainings, :project_id
  end

  def down
    add_column :trainings, :name, :string, default: "", null: false
    add_column :trainings, :description, :text, default: ""
    add_column :trainings, :project_id, :integer
    add_index  :trainings, :project_id

    Training.unscoped do
      Training.all.each do |training| 
        training.update_attributes name: training.training_type.name, description: training.training_type.description, project_id: training.training_type.project_id
      end
    end
    remove_index :trainings, :training_type_id
    remove_column :trainings, :training_type_id
    drop_table :training_types
  end
end
