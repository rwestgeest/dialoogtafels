module City::TrainingInvitationsHelper
  def render_invitation(invitation)
    render partial: 'training_invitation', locals: {training_invitation: invitation}
  end
  def message_subject message
    message.subject 
  end
  def message_info message
    content_tag :span, "door #{message.author_name} op #{l message.created_at, format: :human}", :class => "message-info"
  end
  def notification_check_box person, clazz
    [check_box_tag("notify_person_#{person.id}", person.id, false, :name => "notify_people[]", :class => clazz),
     label_tag(person.name)].join.html_safe
  end
  def new_training_invitation_form(training)
    render :partial => 'new_training_invitation_form', locals: {training: training}
  end
end
