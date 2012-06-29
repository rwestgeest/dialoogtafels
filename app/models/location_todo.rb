class LocationTodo < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  attr_accessible :name
  belongs_to :project, :inverse_of => :location_todos
  has_many :finished_location_todos, :inverse_of => :location_todo, :dependent => :destroy

  validates :name, :presence => true

  def done_for_location?(location)
    finished_location_todos.find_by_location_id(location.id) != nil
  end

  def done_by_for_location(location)
    return nil unless done_for_location?(location)
    finished_location_todos.find_by_location_id(location.id).account_name
  end

  def progress
    return 100 if project.location_count == 0
    100 * finished_location_todos.count / project.location_count
  end
end
