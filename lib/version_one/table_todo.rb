module VersionOne
class TableTodo < VersionOneRecord
  belongs_to :project, :inverse_of => :table_todos
  has_many :finished_table_todos, :inverse_of => :table_todo, :dependent => :destroy

  validates :name, :presence => true

  def done_for_table?(table)
    finished_table_todos.find_by_table_id(table.id) != nil
  end

  def done_by_for_table(table)
    return nil unless done_for_table?(table)
    finished_table_todos.find_by_table_id(table.id).account_name
  end

  def progress
    return 100 if project.table_count == 0
    100 * finished_table_todos.count / project.table_count
  end
end
end
