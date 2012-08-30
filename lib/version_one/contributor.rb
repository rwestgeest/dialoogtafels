module VersionOne
class Contributor < VersionOneRecord
  TypesToHuman = {'Leader' => 'gespreksleider','Organizer' => 'tafelorganisator', 'Participant' => 'deelnemer'}.freeze
  belongs_to :person, :autosave => true

  validates_presence_of :person

  delegate :name               , :name=               , :to => :person
  delegate :email              , :email=              , :to => :person
  delegate :email_confirmation , :email_confirmation= , :to => :person
  delegate :organization       , :organization=       , :to => :person
  delegate :address            , :address=            , :to => :person
  delegate :postal_code        , :postal_code=        , :to => :person
  delegate :city               , :city=               , :to => :person
  delegate :birth_date         , :birth_date=         , :to => :person
  delegate :telephone          , :telephone=          , :to => :person
  delegate :diet               , :diet=               , :to => :person
  delegate :handicap           , :handicap=           , :to => :person
  delegate :organizing_city_id , :organizing_city_id= , :to=> :person
  delegate :organizing_city    , :organizing_city=    , :to=> :person
  
  def initialize(attributes={})
    super(:person => Person.new)
    self.attributes = attributes
  end
  def self.find_all_by_organizing_city_id(organizing_city_id, options = {})
    find(:all, { :include => :person, 
                 :conditions => {"people.organizing_city_id" => organizing_city_id}
               }.merge(options))
  end

  def table_name
    table && table.name || "-- vrij --" 
  end

  def table_of_preference_summary
    table_of_preference && table_of_preference.summary || "-- geen --"
  end

  def messages_sender
    organizing_city.messages_sender
  end

  def info_mail_laddress
    organizing_city.info_mail_address
  end

  def human_type
    TypesToHuman[type]
  end

  def summary
    "#{name}  (#{organization})"
  end

  protected
  def contributor_email_unique(options)
    return unless person_email_exists?(options[:scope])
    errors.add(:email, :taken, options.except(:scope).merge(:value => email))
  end

  private
  def person_email_exists?(scope)
    relation = Contributor.includes(:person).where("people.email" => email, 
                                                   "people.organizing_city_id" => organizing_city_id)
    Array.wrap(scope).each do |scope_item|
      scope_value = send(scope_item)
      relation = relation.where(scope_item => scope_value)
    end
    return relation.exists? && relation.first.id != id
  end
end
end
