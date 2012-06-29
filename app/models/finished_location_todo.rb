class FinishedLocationTodo < ActiveRecord::Base
  include ScopedModel
  scope_to_tenant
  attr_accessible :location, :location_todo
  belongs_to :location_todo, :inverse_of => :finished_location_todos
  belongs_to :location, :inverse_of => :finished_location_todos
end
