class AddMailSubjectsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :organizer_confirmation_subject, :string, :null => false, default: "Welkom bij dialoogtafels - er is een account voor je aangemaakt"
    add_column :projects, :participant_confirmation_subject, :string, :null => false, default: "Welkom bij dialoogtafels"
    add_column :projects, :conversation_leader_confirmation_subject, :string, :null => false, default: "Welkom bij dialoogtafels"
  end
end
