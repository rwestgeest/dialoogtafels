class Organizer < Contributor
  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  class UniqueAccountValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value) 
      record.errors.add(attribute, I18n.t("activerecord.errors.models.#{record.class.to_s.underscore}.attributes.#{attribute}.existing")) if Account.find_by_email(value)
    end
  end
  include ScopedModel
  scope_to_tenant
  belongs_to :project

  attr_accessible :email, :name, :telephone

  validates :project, :presence => true
  validates :person, :presence => true


  validates :email, :presence => true,
                    :unique_account => true,
                    :format => {:with => EMAIL_REGEXP }

  validates :name, :presence => true
  validates :telephone, :presence => true

  delegate :email, :to => :person, :allow_nil => true
  delegate :name, :to => :person, :allow_nil => true
  delegate :telephone, :to => :person, :allow_nil => true

  before_validation :associate_to_active_project

  def self.for_project_and_person(project, person)
    organizer = new
    organizer.project = project
    organizer.person = person
    organizer
  end
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
    self.project = tenant.active_project if tenant.present?
  end
end
