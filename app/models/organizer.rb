class Organizer < Contributor
  include ScopedModel
  scope_to_tenant
  has_many :locations, dependent: :destroy

  class UniqueOrganizerValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value) 
      if Organizer.by_email(value).exists?
        record.errors.add(attribute, I18n.t("activerecord.errors.models.#{record.class.to_s.underscore}.attributes.#{attribute}.existing")) 
      end
    end
  end

  scope :by_email, lambda { |email| includes(:person, :account).where("accounts.email = ?", email) }

  validates :email, :presence => true,
                    :unique_organizer => true,
                    :format => {:with => EMAIL_REGEXP }

  def ordinal_value
    0
  end

  def first_landing_page 
    if account.role == Account::Coordinator
      "/city/locations/new?organizer_id=#{to_param}"
    else
      '/organizer/locations/new'
    end
  end

  def self.for_project_and_person(project, person)
    organizer = new
    organizer.project = project
    organizer.person = person
    organizer
  end

end
