class TrainingType < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant

  belongs_to :project

  before_validation :associate_to_active_project
  validates_presence_of :name
  validates_presence_of :project

  private
  def associate_to_active_project
    self.project = tenant.active_project if tenant.present?
  end
end
