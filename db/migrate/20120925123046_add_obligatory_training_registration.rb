class AddObligatoryTrainingRegistration < ActiveRecord::Migration
  def change 
    add_column :projects, :obligatory_training_registration, :boolean, default: false
  end
end
