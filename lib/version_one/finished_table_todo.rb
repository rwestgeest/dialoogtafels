module VersionOne
class FinishedTableTodo < VersionOneRecord
  belongs_to :table_todo, :inverse_of => :finished_table_todos
  belongs_to :table, :inverse_of => :finished_table_todos
end
end
