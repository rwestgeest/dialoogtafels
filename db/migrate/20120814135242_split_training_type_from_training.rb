class SplitTrainingTypeFromTraining < ActiveRecord::Migration
  class TrainingType < ActiveRecord::Base
    attr_accessible :name, :description

  end
  class Training < ActiveRecord::Base
    attr_accessible :name, :description
    belongs_to :training_type
  end

  def up
    create_table :training_types do |t|
      t.string   "name",              :default => "", :null => false
      t.text     "description",       :default => ""
    end

    add_column :trainings, :training_type_id, :integer
    add_index :trainings, :training_type_id

    Training.unscoped do 
      Training.all.each do |training| 
        training.create_training_type! name: training.name, description: training.description 
        training.save!
      end
    end
    remove_column :trainings, :name
    remove_column :trainings, :description
  end

  def down
    add_column :trainings, :name, :string, default: "", null: false
    add_column :trainings, :description, :text, default: ""

    Training.unscoped do
    Training.all.each do |training| 
      training.update_attributes name: training.training_type.name, description: training.training_type.description
    end
    end
    remove_index :trainings, :training_type_id
    remove_column :trainings, :training_type_id
    drop_table :training_types
  end
end
