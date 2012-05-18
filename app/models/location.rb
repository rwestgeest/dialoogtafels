class Location < ApplicationModel
  include ScopedModel
  scope_to_tenant
  belongs_to :project
  belongs_to :organizer

  attr_accessible :name, :address, :postal_code, :city, :organizer_id

  validates_presence_of :name
  validates_presence_of :address
  validates_presence_of :postal_code
  validates_presence_of :city
  validates_presence_of :organizer

  before_validation :associate_to_active_project

  private 
  def associate_to_active_project
    self.project = tenant.active_project if tenant.present?
  end
end
