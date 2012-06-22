class AddSubjectToComment < ActiveRecord::Migration
  def change
    change_table :location_comments do |t|
      t.string :subject, :default => nil
    end
  end
end
