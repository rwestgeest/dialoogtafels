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

  def initialize(*args)
    super(*args)
    write_attribute(:start_time, location && location.start_time) unless start_time
    write_attribute(:end_time, start_time && start_time + default_length.minutes) unless end_time
  end 

  def default_length
    location && location.conversation_length || 0
  end

end
