module VersionOne
class Table < VersionOneRecord
  belongs_to :organizing_city
  belongs_to :site
  belongs_to :organizer
  has_many :participants
  has_many :leaders_preferring_me, :class_name => 'Leader', :foreign_key => 'table_of_preference_id'
  has_many :participants_preferring_me, :class_name => 'Participant', :foreign_key => 'table_of_preference_id'
  has_many :finished_table_todos, :inverse_of => :table, :dependent => :destroy
  has_one :leader

  
  validates_presence_of :name, :message => 'u heeft geen naam ingegeven'
  validates_presence_of :time, :message => 'u heeft geen tijdstip ingegeven'
  validates_presence_of :max_participants, :message => 'u heeft geen maximaal aantal deelnemers ingegeven'
  validates_presence_of :organizer_id, :message => 'u heeft geen organisator ingegeven'
  validates_presence_of :site, :message => 'u heeft geen locatie ingegeven'

  scope :availables, where("full is NULL or full='f'")
  scope :publishables, availables.where("publish_for_participants='t'")

  # tables will belong to project rather than organizing city
  # for now we have a helper accessor to get to the project
  def project 
    organizing_city.current_project
  end

  def todos
    project.table_todos
  end

  def self.create_for_city!(city, attributes = {})
    create!({:organizing_city => city, :time => city.default_table_start_time}.merge(attributes))
  end

  def todo_progress
    return 100 if project.table_todos.empty?
    100 * finished_table_todos.count / project.table_todos.count
  end

  def tick_done(todo_id)
    begin 
      todo_to_tick = project.table_todos.find(todo_id)
      return if todo_to_tick.done_for_table?(self)
      FinishedTableTodo.create(:table => self, :table_todo => todo_to_tick)
    rescue ActiveRecord::RecordNotFound
      # this is ok
    end
  end

  def tick_undone(todo_id)
    finished_todo = FinishedTableTodo.where(:table_todo_id => todo_id, :table_id => self.id).first
    finished_todo && finished_todo.destroy
  end

  def delete_and_release_participants
    participants.each {|p| p.update_attribute(:table_id, nil)}
    leader.update_attribute(:table_id, nil) if leader 
    destroy
  end

  def leader_id=(value)
    Leader.find(leader.id).update_attribute(:table_id, nil) if leader
    begin 
      Leader.find(value).update_attribute(:table_id, id) if value 
    rescue ActiveRecord::RecordNotFound
    end
  end
  
  def leader_id 
    leader && leader.id || nil
  end
    
  def participant_count=(new_value)
    write_attribute "participant_count", new_value
    self.full = true;
  end
  
  def full=(new_full_value)
    return if (participant_count >= max_participants) && new_full_value == false
    write_attribute("full", new_full_value)  
  end
  
  def organizer_name
    organizer.name
  end
  
  def site_name
    site && site.name || ''
  end
  
  def leader_name
    leader && leader.name || ''
  end
    
  def to_s
    time.strftime("%d-%m-%Y %H:%M") + " - " + organizer.name + ' - ' + name   
  end
  
  def summary
    "#{site.name} - #{name} - #{organizer.name} - #{time.strftime('%d-%m-%Y %H:%M')}"    
  end
  
  def text_report
  %Q{======================================================
Tafel #{name}
Dialoogtafel start om : #{time.strftime("%d-%m-%Y %H:%M")}
(zorg dat u als Organisator en Gespreksleider minstens 30 minuten voor aanvang aanwezig bent)
(zorg dat u als deelnemer minstens 15 minuten voor aanvang aanwezig bent)
Geschatte eindtijd    : #{ends_at.strftime("%H:%M")}


Eten / drinken        : #{features}

Locatie:
Naam          : #{site.name}
Adres         : #{site.address}
Postcode      : #{site.postal_code}
Plaats        : #{site.city}

Organisator:
#{person_details(organizer)}
Gespreksleider:
#{person_details(leader)}
Deelnemers (#{participants.size}):
#{participants.collect {|participant| person_details(participant)}.join("\n")}
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
end
end
