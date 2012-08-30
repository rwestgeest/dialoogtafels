module VersionOne
class TableSummaryMessage < Message
  class Instance < VersionOne::Message::Instance
    attr_reader :table
    def initialize(message, table)
      super(message)
      @table = table
    end

    def body
      commencement + " " + table_name + $/ + $/ +
      super + $/ + $/ +
      table_text_report 
    end
    
    def recepients
      message.recepients(table)
    end

    def ==(other)
      return false unless other.is_a?(Instance)
      return message == other.message && table == other.table
    end
    
    def to_s
      "table summary message instance for message #{message.id} and table #{table_name}"
    end
    alias_method :inspect, :to_s
    
    
    private 
    def table_text_report
      table && table.text_report || "<geen tafel beschikbaar>" 
    end
    def table_name
      table && table.name || "<geen tafel>"
    end
  end
  
  class TestInstance < Instance
    def recepients
      message.test_recepient
    end
    
    def ==(other)
      return false unless other.is_a?(TestInstance)
      return message == other.message && table == other.table
    end
    def to_s
      "TEST message for message #{message.id} and table #{table.name}"
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

    All = RecepientList.new("all", "Tafelorganisator(en) en Gespreksleider(s) en Deelnemers") do |table|
      result = []
      result << table.organizer.email if table.organizer
      result << table.leader.email if table.leader
      result + table.participants.collect {|p| p.email}.compact
    end
    
    OrganizerAndLeader = RecepientList.new("organizer_and_leader", "Tafelorganisator(en) en Gespreksleider(s)") do |table|
      result = []
      result << table.organizer.email if table.organizer
      result << table.leader.email if table.leader
      result
    end
    
    OrganizerOnly = RecepientList.new("organizer_only", "Tafelorganisator(en)") do |table|
      result = []
      result << table.organizer.email if table.organizer
      result
    end
    
    LeaderOnly = RecepientList.new("leader_only", "Gespreksleider(s)") do |table|
      result = []
      result << table.leader.email if table.leader
      result
    end
    
    def self.all
      return All
    end
    
    def self.organizer_and_leader
      return OrganizerAndLeader
    end
    
    def self.organizer_only
      return OrganizerOnly
    end
    
    def self.leader_only
      return LeaderOnly
    end
    
    def self.participants_only
      return ParticipantOnly
    end
    
    def self.from_list_type(list_type_string) 
      return OrganizerAndLeader unless @@list_types.has_key?(list_type_string)
      @@list_types[list_type_string]
    end
    
    def contents(table)
      @list_retrieval_block.call(table)
    end
  end

  def allowed_recepient_lists
   [ RecepientList.organizer_only, 
     RecepientList.leader_only, 
     RecepientList.organizer_and_leader,
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
  
  def recepients(table)
    result = recepient_list.contents(table)
    return result.first if result.length == 1
    return sender if result.empty?
    return result
  end

  def template_name
    'table_summary_message'
  end
  
  def message_type
    "Tafeloverzicht"
  end

  def create_test_instance
    TestInstance.new(self, organizing_city.first_table)
  end

  def instances(&block)
    applicable_tables.each do |table|   
      yield Instance.new(self, table)
    end
  end
end

end
