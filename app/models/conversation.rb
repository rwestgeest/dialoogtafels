class Conversation < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  belongs_to :location
  attr_accessible :start_date, :start_time, :end_date, :end_time, :location_id, :location, :number_of_tables
  validates_presence_of :start_date
  validates_presence_of :start_time
  validates_presence_of :end_date
  validates_presence_of :end_time

  def initialize(*args)
    super(*args)
    self.start_date = location && location.start_date unless start_date
    self.end_date = start_date unless end_date
    self.start_time = location && location.start_time unless start_time
    self.end_time = start_time && start_time + default_length.minutes unless end_time
  end

  def default_length
    location && location.conversation_length || 0
  end
end
