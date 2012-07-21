class Contributor < ApplicationModel
  attr_accessible :email, :name, :telephone, :conversation, :person
  belongs_to :person 
  belongs_to :project
  has_one :account, :through => :person

  scope :for_project, lambda { |project_id| where('project_id' => project_id) }
  scope :by_email_and_conversation_id, 
        lambda { |email, conversation_id| includes(:person, :account).where('accounts.email' => email).where('conversation_id' => conversation_id) }

  before_validation :associate_to_active_project
  EMAIL_REGEXP = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  class UniqueContributorValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value) 
      if Contributor.by_email_and_conversation_id(value, record.conversation_id).exists?
        record.errors.add(attribute, I18n.t("activerecord.errors.models.#{record.class.to_s.underscore}.attributes.#{attribute}.existing")) 
      end
    end
  end


  validates :project, :presence => true
  validates :person, :presence => true
  validates :name, :presence => true
  validates :telephone, :presence => true

  delegate :email, :to => :person, :allow_nil => true
  delegate :name, :to => :person, :allow_nil => true
  delegate :telephone, :to => :person, :allow_nil => true


  def email=(email) 
    return unless email
    unless person && person.persisted?
      located_person = Person.includes(:account).where("lower(accounts.email) = ?", email.downcase).first
      self.person = located_person && located_person || Person.new
    end
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

  def type_name
    @type_name ||= 'contributor.type.' + self.class.to_s.underscore
  end

  private 
  def associate_to_active_project
    self.project = tenant.active_project if tenant.present? && !project.present?
  end
end
