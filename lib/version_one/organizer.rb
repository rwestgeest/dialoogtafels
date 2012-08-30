module VersionOne
class Organizer < Contributor
  
  has_many :tables
  belongs_to :account, :dependent => :destroy
  has_many :unassigned_leaders,
    :through => :tables,
    :source => :leaders_preferring_me,
    :conditions => 'contributors.table_id is null'
  has_many :preferred_unassigned_participants,
    :through => :tables,
    :source => :participants_preferring_me,
    :conditions => 'contributors.table_id is null'

  has_many :sites, :order => 'name'

  validate :organizer_email_unique

  def self.for_organizing_city(city, attributes = {})
    new({ :organizing_city_id => city.id }.merge(attributes))
  end
  def other_unassigned_participants
    organizing_city.participants.find :all,
      :conditions => 'contributors.table_id is null and contributors.table_of_preference_id is null'
  end

  def save_with_account_creation!
    was_new_record = new_record?
    self.account = Account.generate_for(self) if self.valid?
    if save!
      confirm! if was_new_record && !@confirmation_skip
      return true
    end
    return false
  end

  def skip_confirmation
    @confirmation_skip = true
  end

  def confirm!
    Postman.deliver(:organizer_application_confirmation, self)
    organizing_city.notify_application(self, "organisator")
  end

  def self.create_new creation_attributes
    organizer = Organizer.new(creation_attributes)
    return organizer unless organizer.valid?
    organizer.account = Account.generate_for(organizer)
    organizer.transaction do
      if organizer.save
        Postman.deliver(:organizer_application_confirmation, organizer)
        organizer.organizing_city.notify_application(organizer, "organisator")
      end
    end
    return organizer
  end

  def my_table?(table)
    tables.include?(table)
  end

  def available_sites
    sites
  end

  protected
  def organizer_email_unique
    contributor_email_unique(:scope => :type, :message => 'een organisator met dit email adres bestaat al')
  end
end
end
