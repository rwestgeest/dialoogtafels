class AddConfirmationTextsToProject < ActiveRecord::Migration
  def up
    add_column :projects, :organizer_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als tafelorganistor aan de dag van de dialoog."
    add_column :projects, :participant_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als deelnemer aan de dag van de dialoog."
    add_column :projects, :conversation_leader_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als gespreksleider aan de dag van de dialoog."
    Project.reset_column_information
    Project.unscoped do
      Project.all.each do |project|
        if project.tenant
          project.update_attributes :organizer_confirmation_text => project.tenant.organizer_confirmation_text,
                                    :conversation_leader_confirmation_text => project.tenant.conversation_leader_confirmation_text,
                                    :participant_confirmation_text => project.tenant.participant_confirmation_text
        end
      end
    end
    remove_column :tenants, :organizer_confirmation_text
    remove_column :tenants, :conversation_leader_confirmation_text
    remove_column :tenants, :participant_confirmation_text
  end
  def down
    add_column :tenants, :organizer_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als tafelorganistor aan de dag van de dialoog."
    add_column :tenants, :participant_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als deelnemer aan de dag van de dialoog."
    add_column :tenants, :conversation_leader_confirmation_text, :text, default: "Welkom,\n\nDankje voor je aanmelding als gespreksleider aan de dag van de dialoog."
    Tenant.reset_column_information
    Tenant.unscoped do
      Tenant.all.each do |tenant|
        if tenant.projects.last
        tenant.update_attributes :organizer_confirmation_text => tenant.projects.last.organizer_confirmation_text,
                                  :conversation_leader_confirmation_text => tenant.projects.last.tenant.conversation_leader_confirmation_text,
                                  :participant_confirmation_text =>  tenant.projects.last.participant_confirmation_text
        end
      end
    end
    remove_column :projects, :organizer_confirmation_text
    remove_column :projects, :conversation_leader_confirmation_text
    remove_column :projects, :participant_confirmation_text
  end
end
