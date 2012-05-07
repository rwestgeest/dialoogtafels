class Organizer < Contributor
  attr_accessible :email, :name, :telephone

  validates :email, :presence => true
  validates :name, :presence => true
  validates :telephone, :presence => true

  delegate :email, :to => :person, :allow_nil => true
  delegate :name, :to => :person, :allow_nil => true
  delegate :telephone, :to => :person, :allow_nil => true

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

end
