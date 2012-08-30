module VersionOne
class Site < VersionOneRecord
  has_many :tables, :autosave => true
  belongs_to :organizing_city
  belongs_to :organizer
  validates_presence_of :name, :message => 'u heeft geen naam ingegeven'
  validates_uniqueness_of :name, :scope => :organizer_id, :message => 'u heeft al een locatie met deze naam'
  validates_presence_of :organizer, :message => 'u heeft geen organisator ingegeven'

  scope :without_location_info, where("lattitude = '0' and longitude = '0'").includes(:organizing_city).order("organizing_cities.name")

  delegate :name, :to => :organizer, :prefix => :organizer, :allow_nil => true
  def self.create_by_name_and_city(name, city)
    self.create(:name => name, :organizing_city_id => city.id)
  end  

  def self.for_organizer(organizer, attributes ={})
    new({:organizing_city => organizer.organizing_city, :organizer => organizer}.merge(attributes))
  end

  def self.without_organizer
    includes(:organizing_city, :tables).order("organizing_cities.name").select {|s| s.organizer == nil} 
  end

  def amount=(value)
    @amount = value.to_i
  end

  def amount
    @amount
  end
end
end
