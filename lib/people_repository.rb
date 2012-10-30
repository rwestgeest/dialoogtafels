class PeopleRepository < Struct.new(:people_repository)
  def for_date_range(start_date, end_date)
    DateRangedPeopleRepository.new(self, start_date, end_date)
  end

  def coordinators
    TenantAccount.coordinators
  end 

  def organizers
    people_repository.organizers
  end

  def conversation_leaders
    people_repository.conversation_leaders
  end

  def participants
    people_repository.participants
  end
end

class DateRangedPeopleRepository < PeopleRepository 
  def initialize(people_repository, start_date, end_date)
    super(people_repository)
    @start_date = start_date
    @end_date = end_date
  end 
  def organizers
    in_range(super.includes(:locations => :conversations))
  end
  def conversation_leaders
    in_range(super.includes(:conversation))
  end
  def participants
    in_range(super.includes(:conversation))
  end

  private
  def in_range(relation)
    relation
    .where('conversations.start_time >= ?', @start_date)
    .where('conversations.start_time <= ?', @end_date.tomorrow)
  end
end
