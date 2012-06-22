module City::CommentsHelper
  def render_nested comments
    comments.map do |comment, children|
      render_comment(comment) + content_tag(:div, render_nested(children), :class => 'nested-comment')
    end.join.html_safe
  end
  def render_comment comment
    render(partial: 'location_comment', locals: {location_comment:comment})
  end
  def comment_subject comment
    comment.subject 
  end
  def comment_info comment
    content_tag :span, "door #{comment.author_name} op #{l comment.created_at, format: :human}", :class => "comment-info"
  end
  def parent_reference(comment, form)
     form.hidden_field(:parent_id) if comment
  end
  def new_comment_form(location, parent_comment = nil)
    render :partial => 'new_comment_form', locals: {location: location, parent_comment: parent_comment}
  end
  def notification_check_box person, clazz
    [check_box_tag("notify_person_#{person.id}", person.id, false, :name => "notify_people[]", :class => clazz),
     label_tag(person.name)].join.html_safe
  end
end
