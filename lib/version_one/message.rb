module VersionOne


class Message < VersionOneRecord
  Prepared= "Prepared"
  Verified= "Verified"
  InDelivery= "InDelivery"
  Testing=  "Testing"
  Delivered="Delivered"

  class InvalidStateException < Exception
    def initialize(message) super(message); end
  end

  def self.create_table_invitation organizing_city
    TableSummaryMessage.create(:sender => organizing_city.messages_sender,
                :sent_at => DateTime.now,
                :test_recepient => organizing_city.messages_default_test_email,
                :subject => "<type onderwerp hier>",
                :commencement => "<type aanhef hier>",
                :organizing_city => organizing_city)
  end
  
  def self.create_mailing organizing_city
    MailingMessage.create(:sender => organizing_city.messages_sender,
                :sent_at => DateTime.now,
                :test_recepient => organizing_city.messages_default_test_email,
                :subject => "<type onderwerp hier>",
                :commencement => "<type aanhef hier>",
                :organizing_city => organizing_city)
  end
  
  def self.create_training_invitation_for training
    training = Training.find(training) if training.is_an_id?
    organizing_city = training.organizing_city
    message = TrainingInvitationMessage.for_training(training,
                :sender => organizing_city.messages_sender,
                :sent_at => DateTime.now,
                :test_recepient => organizing_city.messages_default_test_email,
                :subject => "<type onderwerp hier>",
                :commencement => "<type aanhef hier>",
                :organizing_city => organizing_city)
     message.save!
     return message
  end

  
  class Instance
    protected 

    attr_reader :message
    def initialize(message)
      @message = message
    end

    public    
    
    def commencement
      message.commencement
    end
    
    def body
      message.body_text
    end
      
    def sent_at
      message.sent_at
    end
    
    def sender
      message.sender
    end
    
    def subject
      message.subject 
    end
    
    def cc_mail
      message.cc_mail
    end
  end

  belongs_to :organizing_city
  belongs_to :table
  belongs_to :organizer

  validates_presence_of :organizing_city_id, :message => 'deze boodschap item is niet verbonden aan uw stad - neem contact op met uw beheerder'
  validates_presence_of :commencement, :message => 'u heeft geen aanhef ingegeven'
  validates_presence_of :subject, :message => 'u heeft geen onderwerp ingegeven'
  validates_presence_of :sender, :message => 'u heeft geen "Van" ingegeven'
  validates_presence_of :test_recepient, :message => 'u heeft geen "test versie naar" ingegeven'
   
  def cc_mail
    organizing_city.info_mail_address
  end
  
  def message_type
    "onbekend" 
  end
  
  def deliver_test
    uh_oh("kan niet testen in #{human_state}") unless [Prepared, Verified, Testing].include? status
    Postman.deliver(:generic_message,create_test_instance)
    self.status=Testing 
  end  

  def create_test_instance
    uh_oh "create test instance not defined"
  end    
  
  def verify ok=true
    uh_oh("kan niet testen in #{human_state}") unless  [Testing, Verified].include? status
    self.status= ok ? Verified : Prepared
  end

  def start_delivery
    uh_oh("kan niet leveren in #{human_state}") unless Verified == status
    Delayed::Job.enqueue MailingDeliveryJob.new(self)
    self.status = InDelivery
  end

  def deliver
    uh_oh("kan niet verzenden in #{human_state}") unless status == InDelivery
    self.sent_at = Time.now
    instances do |instance|   
      Postman.deliver(:generic_message, instance)
    end
    self.status = Delivered
  end

  def deliver_and_save
    uh_oh("kan niet verzenden in #{human_state}") unless status == Verified
    _deliver_and_save
  end

  def _deliver_and_save
    self.transaction do
      deliver
      save
    end
  end
  # handle_asynchronously :_deliver_and_save

  def instances(&block)
    uh_oh "instances creator not defined"
  end
  
  HUMAN_STATE = {Prepared => "Voorbereid", 
                 Verified => "Klaar om te verzenden",
                 Testing => "Test versie verzonden",
                 InDelivery => "Wordt verzonden",
                 Delivered => "Verzonden"}
   
  def human_state
    HUMAN_STATE[status]
  end    
  
  AVAILABLE_ACTIONS = {Prepared => [:deliver_test],
                       Testing => [:verify, :deliver_test],
                       Verified => [:deliver_test, :deliver],
                       InDelivery => [],
                       Delivered => []}
     
  def available_actions
     return AVAILABLE_ACTIONS[status]
  end
  
  private 
  def uh_oh message
    raise InvalidStateException.new(message)
  end
  
  def applicable_tables
    organizer && organizing_city.tables_for_organizer(organizer) || organizing_city.tables
  end
end
end
