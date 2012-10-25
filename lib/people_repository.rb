class PeopleRepository < Struct.new(:project)
  def coordinators
    TenantAccount.coordinators
  end 

  def organizers
    project.organizers
  end

  def conversation_leaders
    project.conversation_leaders
  end

  def participants
    project.participants
  end
end
