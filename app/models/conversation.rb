class Conversation < ActiveRecord::Base
  include Schedulable

  attr_accessible :start_date, :start_time, :end_date, :end_time, :location_id, :location, :number_of_tables
  

  include ScopedModel
  scope_to_tenant
  
  belongs_to :location
  has_many :participants
  has_many :conversation_leaders

  validates_presence_of :start_date
  validates_presence_of :start_time
  validates_presence_of :end_date
  validates_presence_of :end_time

  scope :availables, 
                includes(:location => :project).where("conversations.conversation_leader_count < conversations.number_of_tables")
                 .where("conversations.participant_count < (number_of_tables * projects.max_participants_per_table)")

  def initialize(*args)
    super(*args)
    write_attribute(:start_time, location && location.start_time) unless start_time
    write_attribute(:end_time, start_time && start_time + default_length.minutes) unless end_time
  end 

  def default_length
    location && location.conversation_length || 0
  end

  def max_conversation_leaders
    number_of_tables
  end

  def max_participants
    number_of_tables * location.max_participants_per_table
  end

end
