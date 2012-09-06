class Project < ActiveRecord::Base
  include Schedulable
  include ScopedModel
  scope_to_tenant

  attr_accessible :name, :max_participants_per_table, :conversation_length, 
                  :start_date, :start_time, :organizer_confirmation_text, 
                  :participant_confirmation_text, :conversation_leader_confirmation_text

  validates :name, :presence => true
  validates :max_participants_per_table, 
    :presence => true,
    :numericality => true

  validates :conversation_length, 
    :presence => true,
    :numericality => true

  has_many :location_todos, :inverse_of => :project
  has_many :locations

  def initialize(*attrs) 
    super(*attrs)
  end

  def for_tenant(tenant)
    self.tenant = tenant
    return self
  end

  def start_time
    super || Time.now
  end

  def location_count
    locations.count
  end

end
