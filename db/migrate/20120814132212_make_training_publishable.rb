class MakeTrainingPublishable < ActiveRecord::Migration
  def up
    add_column :projects, :trainings_on_form, :boolean, :default => true
    execute "update projects set trainings_on_form = 't'"
  end

  def down
    remove_column :projects, :trainings_on_form
  end
end
