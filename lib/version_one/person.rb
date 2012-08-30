module VersionOne
class Person < VersionOneRecord
  belongs_to :organizing_city
  has_many :participants, :dependent => :destroy
  has_many :organizers, :dependent => :destroy
  has_many :leaders, :dependent => :destroy
  has_many :contributors

  validates_presence_of :organizing_city, :message => 'deze persoon is niet aan uw stad gekoppeld - neem contact op met uw beheerder'
  validates_presence_of :name, :message => 'u heeft geen naam ingegeven'
  validates_presence_of :email, :message => 'u heeft geen email adres ingegeven'
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :message => 'u heeft een ongeldig email adres ingegeven'
  validates_confirmation_of :email, :message => 'het controle email adres is niet gelijk aan het email adres'
  validates_presence_of :telephone, :message => 'u heeft geen telefoon nummer ingegeven'
  validates_presence_of :address, :message => 'u heeft geen adres ingegeven'
  validates_presence_of :postal_code, :message => 'u heeft geen postcode ingegeven'
  validates_presence_of :city, :message => 'u heeft geen woonplaats ingegeven'

  def summary
    "#{name}  (#{organization})"
  end
end
end
