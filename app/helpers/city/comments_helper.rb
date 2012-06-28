module City::CommentsHelper
  include ::MessagesHelper
  def render_nested comments
    comments.map do |comment, children|
      render_comment(comment) + content_tag(:div, render_nested(children), :class => 'nested-message')
    end.join.html_safe
  end
  def render_comment comment
    render(partial: 'location_comment', locals: {location_comment:comment})
  end
  def parent_reference(comment, form)
     form.hidden_field(:parent_id) if comment
  end
  def new_comment_form(location, parent_comment = nil)
    render :partial => 'new_comment_form', locals: {location: location, parent_comment: parent_comment}
  end
end
