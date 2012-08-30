module VersionOne
class Training < VersionOneRecord
  belongs_to :organizing_city
  has_many :training_registrations, :include => :leader
  has_many :participants, :through => :training_registrations, :source => :leader

  before_destroy :refuse_destroy_if_has_registrations

  validates_presence_of :time, :message => "u heeft geen tijdstip ingegeven"
  validates_uniqueness_of :time, :scope => :location, :message => 'op deze tijd bestaat al een training'
  validates_presence_of :location, :message => "u heeft geen locatie ingegeven"
  
  def uninvited_training_registrations
    training_registrations.select { |registration| !registration.invited? } 
  end
  
  def first_leader 
    training_registrations.first.leader if training_registrations.length > 0 
  end
  
  def register(participant)
    participants << participant
    update_attribute(:participant_count, participants.count)
  end

  def cancel_registration(participant)
    participants.delete(participant)
    update_attribute(:participant_count, participants.count)
  end
  
  def details
    to_s
  end
  
  def to_s
    location + ' - ' + time.strftime("%d-%m-%Y %H:%M")
  end
  
  def readable_date
    time.strftime("%d-%m-%Y")
  end
  
  def text_report
  %Q{======================================================
Training #{location} #{time.strftime("%d-%m-%Y %H:%M")}

Deelnemers (#{training_registrations.size}):
#{training_registrations.collect {|participant| person_details(participant)}.join("\n")}
}
    
  end
  
  def person_details(person)
    return "-" unless person
    %Q{Naam          : #{person.name}    
Telefoon      : #{person.telephone}
e-mail        : #{person.email}
Dieetwensen   : #{person.diet}
Voorzieningen : #{person.handicap}
}
  end

  
  private  
  def refuse_destroy_if_has_registrations
    return false if participants.count > 0
  end

end
end
