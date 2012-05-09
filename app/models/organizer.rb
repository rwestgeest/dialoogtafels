class Organizer < Contributor
  include ScopedModel
  scope_to_tenant

  belongs_to :project

  validates:project, :presence => true

  attr_accessible :email, :name, :telephone

  validates :email, :presence => true
  validates :name, :presence => true
  validates :telephone, :presence => true

  delegate :email, :to => :person, :allow_nil => true
  delegate :name, :to => :person, :allow_nil => true
  delegate :telephone, :to => :person, :allow_nil => true

  before_create :associate_to_active_project

  def email=(email) 
    self.person = Person.new unless person
    person.email = email
  end

  def name=(name)
    self.person = Person.new unless person
    person.name = name
  end

  def telephone=(name)
    self.person = Person.new unless person
    person.telephone = name
  end

  private 
  def associate_to_active_project
    self.project = Tenant.active_project
  end
end
