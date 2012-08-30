require 'version_one/version_one_record'
module VersionOne
  class << self
    def load_database(filename)
      raise "#{filename} does not exist" unless File.exists?(filename)
      VersionOneRecord.establish_connection :adapter => 'sqlite3', :database => filename
      require 'version_one/message.rb'
      require 'version_one/contributor.rb'
      require 'version_one/finished_table_todo.rb'
      require 'version_one/abstract_participant.rb'
      require 'version_one/project.rb'
      require 'version_one/account.rb'
      require 'version_one/training.rb'
      require 'version_one/participant.rb'
      require 'version_one/table_todo.rb'
      require 'version_one/site.rb'
      require 'version_one/leader.rb'
      require 'version_one/mailing_message.rb'
      require 'version_one/person.rb'
      require 'version_one/time_slot.rb'
      require 'version_one/table_summary_message.rb'
      require 'version_one/image_caching.rb'
      require 'version_one/version_one_record.rb'
      require 'version_one/table.rb'
      require 'version_one/preferred_time_slot.rb'
      require 'version_one/email_notifier.rb'
      require 'version_one/organizer.rb'
      require 'version_one/admin.rb'
      require 'version_one/training_invitation_message.rb'
      require 'version_one/organizing_city.rb'
      require 'version_one/training_registration.rb'
    end
  end
end
