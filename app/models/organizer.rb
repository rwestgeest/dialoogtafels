class Organizer < Contributor
  include ScopedModel
  scope_to_tenant
  has_many :locations

  validates :email, :presence => true,
                    :format => {:with => EMAIL_REGEXP }

  def ordinal_value
    0
  end

  def self.for_project_and_person(project, person)
    organizer = new
    organizer.project = project
    organizer.person = person
    organizer
  end

end
