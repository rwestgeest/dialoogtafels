class AddConfirmationTextsToTenant < ActiveRecord::Migration
  def change
    add_column :tenants, :organizer_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als deelnemer aan de dag van de dialoog.\n\nEr is een account voor je aangemaakt.\n\nGebruik de onderstaande link om je account te bevestigen en locaties aan te melden."
    add_column :tenants, :participant_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als deelnemer aan de dag van de dialoog.\n\nHieronder vind je de details van je aanmelding."
    add_column :tenants, :conversation_leader_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als deelnemer aan de dag van de dialoog.\n\nHieronder vind je de details van je aanmelding."
  end
end
