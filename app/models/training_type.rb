class TrainingType < ActiveRecord::Base
  attr_accessible :name, :description
  include ScopedModel
  scope_to_tenant

  belongs_to :project
  has_many :trainings, order: :start_time

  before_validation :associate_to_active_project
  validates_presence_of :name
  validates_presence_of :project

  def available_trainings
    trainings.availables
  end

  private
  def associate_to_active_project
    self.project = tenant.active_project if tenant.present?
  end
end
