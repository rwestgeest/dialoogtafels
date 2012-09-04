class AddConfirmationTextsToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :organizer_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als tafelorganistor aan de dag van de dialoog."
    add_column :tenants, :participant_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als deelnemer aan de dag van de dialoog."
    add_column :tenants, :conversation_leader_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als gespreksleider aan de dag van de dialoog."
  end
end
