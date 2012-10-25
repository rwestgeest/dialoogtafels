class RepositorySaveException < Exception
  attr_reader :object_that_failed_to_save

  def initialize(object_that_failed_to_save)
    @object_that_failed_to_save = object_that_failed_to_save
  end
end

class MailingRepository < Struct.new(:mailing_controller, :project, :author)
  class NullMailingRepository
    def create_mailing(mailing_message, recepient_list)
    end
  end

  def self.null
    NullMailingRepository.new
  end

  def create_mailing(mailing_message, recepient_list)
    begin 
      mailing_message.reference = project
      mailing_message.author = author

      mailing_message.save!
    rescue ActiveRecord::RecordInvalid
      raise RepositorySaveException.new(mailing_message)
    end
  end
end
