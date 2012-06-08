class Conversation < ActiveRecord::Base
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

  def start_date=(new_value)
    set_date_value(:start, new_value)
  end

  def start_date
    start_time && start_time.to_date || nil
  end

  def start_time=(new_value)
    set_time_value(:start, new_value)
  end

  def end_date=(new_value)
    set_date_value(:end, new_value)
  end

  def end_date
    end_time && end_time.to_date || nil
  end

  def end_time=(new_value)
    set_time_value(:end, new_value)
  end

  private 

  def set_date_value(which_date, new_value)
    return if new_value.nil?
    date_attr = :"#{which_date}_date"
    time_attr = :"#{which_date}_time"
    time_value = send(time_attr)

    new_value = new_value.is_a?(Date) && new_value || new_value.to_date

    write_attribute(time_attr, build_time(new_value, time_value))
  end

  def set_time_value(which_time, new_value)
    return if new_value.nil?
    time_attr = :"#{which_time}_time"
    previous_value = send(time_attr) || Time.now

    new_value = new_value.is_a?(Time) && new_value || new_value.to_time(:local)

    write_attribute(time_attr, build_time(previous_value, new_value))
  end

  def build_time(date, time)
    time_params = [ date.year, date.month, date.mday ]
    time_params +=  [ time.hour, time.min, time.sec ] if time
    return Time.local(*time_params)
  end
end
