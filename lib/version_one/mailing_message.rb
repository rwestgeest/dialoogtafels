module VersionOne
class MailingMessage < Message


  class InstanceBase < VersionOne::Message::Instance
    def body
      commencement + " " + recepient_name + " " + $/ + $/ + 
      super
    end
  end

  class Instance < InstanceBase
    attr_reader :recepient

    def initialize(message, recepient)
      super(message)
      @recepient = recepient
    end

    def recepients
      recepient.email
    end

    def ==(other)
      return false unless other.is_a?(Instance)
      return message == other.message && recepient == other.recepient
    end

    def to_s
      "mailing message instance for message #{message.id} and recepient #{recepient_name}"
    end
    alias_method :inspect, :to_s

    private
    def recepient_name
      recepient.name
    end
  end

  class TestInstance < InstanceBase
    def recepients
      message.test_recepient
    end

    def ==(other)
      return false unless other.is_a?(TestInstance)
      return message == other.message 
    end

    def to_s
      "TEST message for message #{message.id}"
    end

    private 
    def recepient_name
      "<hier komt de naam van de geadresseerde>"
    end
  end

  class RecepientList
    attr_reader :list_type, :human_representation
    cattr_reader :list_types
    @@list_types = {}

    def self.register_recepient_list(list_type_string, recepientlist)
      @@list_types[list_type_string] = recepientlist
    end
    
    def initialize(list_type, human_representation, &list_retrieval_block)      
      @list_type = list_type
      @human_representation = human_representation
      @list_retrieval_block = list_retrieval_block
      RecepientList.register_recepient_list(list_type, self)
    end

    All = RecepientList.new("all", "Tafelorganisator(en) en Gespreksleider(s) en Deelnemers") do |organizing_city|
      organizing_city.organizers + organizing_city.leaders +  organizing_city.participants
    end
    
    OrganizerAndLeader = RecepientList.new("organizer_and_leader", "Tafelorganisator(en) en Gespreksleider(s)") do |organizing_city|
      organizing_city.organizers + organizing_city.leaders
    end
    
    OrganizerOnly = RecepientList.new("organizer_only", "Tafelorganisator(en)") do |organizing_city|
      organizing_city.organizers
    end
    
    LeaderOnly = RecepientList.new("leader_only", "Gespreksleider(s)") do |organizing_city|
      organizing_city.leaders
    end
    
    ParticipantOnly = RecepientList.new("participant_only", "Deelnemer(s)") do |organizing_city|
      organizing_city.participants
    end
    
    def self.all
      return All
    end
    
    def self.organizers_and_leaders
      return OrganizerAndLeader
    end
    
    def self.organizers_only
      return OrganizerOnly
    end
    
    def self.leaders_only
      return LeaderOnly
    end
    
    def self.participants_only
      return ParticipantOnly
    end
    
    def self.from_list_type(list_type_string) 
      return OrganizerAndLeader unless @@list_types.has_key?(list_type_string)
      @@list_types[list_type_string]
    end
    
    def contents(organizing_city)
      @list_retrieval_block.call(organizing_city)
    end
  end

  def template_name
    'mailing_message'
  end

  def message_type
    subject
  end

  def allowed_recepient_lists
   [ RecepientList.organizers_only, 
     RecepientList.leaders_only, 
     RecepientList.participants_only, 
     RecepientList.organizers_and_leaders,
     RecepientList.all]
  end

  def recepient_list_type=(recepient_list_type)
    recepient_list_type = recepient_list_type.list_type if (recepient_list_type.is_a?(RecepientList))
    write_attribute :recepient_list_type, recepient_list_type
  end

  def recepient_list_type
    result = read_attribute(:recepient_list_type)
    result.empty? && 'organizer_and_leader' || result
  end

  def recepient_list
    RecepientList.from_list_type(recepient_list_type)
  end

  def create_test_instance
    TestInstance.new(self)
  end

  def instances(&block)
    recepients = recepient_list.contents(organizing_city)
    recepients.each { |recepient| yield Instance.new(self, recepient) }
  end

end
end
