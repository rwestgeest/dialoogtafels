module VersionOne
class Admin < Account
  def self.all_admins
    Account.find :all, :conditions => "role = 'admin'"
  end
  
  def self.notify_application(participant, type_of_application)

    all_admins.each do |admin|
      EmailNotifier.deliver_application_notification(admin, participant, type_of_application)
    end
  end
end
end
