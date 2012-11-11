class AddNotificationEmailsToTenant < ActiveRecord::Migration
  def up
    add_column :tenants, :notification_emails, :string
  end
  def down
    remove_column :tenants, :notification_emails
  end
end
