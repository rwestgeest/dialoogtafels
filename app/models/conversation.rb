class Conversation < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  belongs_to :location
  attr_accessible :start_date, :start_time, :end_date, :end_time, :location_id
  validates_presence_of :start_date
  validates_presence_of :start_time
  validates_presence_of :end_date
  validates_presence_of :end_time

end
