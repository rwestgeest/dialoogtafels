class RepositorySaveException < Exception
  attr_reader :object_that_failed_to_save

  def initialize(object_that_failed_to_save)
    @object_that_failed_to_save = object_that_failed_to_save
  end
end

class MailingRepository < Struct.new(:project, :author)
  class NullMailingRepository
    def create_mailing(mailing_message)
    end
  end

  def self.null
    NullMailingRepository.new
  end

  def create_mailing(mailing_message)
    begin 
      mailing_message.reference = project
      mailing_message.author = author

      mailing_message.save!
      return mailing_message
    rescue ActiveRecord::RecordInvalid
      raise RepositorySaveException.new(mailing_message)
    end
  end

  def mailing_messages
    project.mailing_messages
  end
end
