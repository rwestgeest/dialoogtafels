class Project < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant

  attr_accessible :name, :max_participants_per_table
  validates :name, :presence => true

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
