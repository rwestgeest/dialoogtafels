class AddAttachementToMailingMessage < ActiveRecord::Migration
  def change
    change_table :messages do |t|
      t.boolean :attach_registration_info, :default => false
    end
  end
end
