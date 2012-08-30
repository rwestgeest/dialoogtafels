module VersionOne
class Project < VersionOneRecord
  has_many :table_todos, :inverse_of => :project
  belongs_to :organizing_city
  belongs_to :current_for_organizing_city, :class_name => 'OrganizingCity'

  def table_count
    organizing_city.table_count
  end

  def default_table_start_time
    unless read_attribute(:default_table_start_time) 
      write_attribute(:default_table_start_time, Time.now)
    end
    super
  end

  def expose_email_in_map?
    expose_email_in_map
  end

end
end
