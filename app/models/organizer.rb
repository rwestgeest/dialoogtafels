class Organizer < Contributor
  include ScopedModel
  scope_to_tenant

  validates :email, :presence => true,
                    :unique_account => true,
                    :format => {:with => EMAIL_REGEXP }


  def self.for_project_and_person(project, person)
    organizer = new
    organizer.project = project
    organizer.person = person
    organizer
  end

end
