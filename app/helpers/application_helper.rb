module ApplicationHelper
  def title(title)
    content_for(:title) { title }
  end

  def page_info(page_info)
    content_for(:page_info, page_info)
  end

  def page_side_bar(side_bar)
    content_for(:page_side_bar, side_bar)
  end

  def selected_text(text)
    content_tag :span, text, :class => 'selected-text'
  end

  def parent_layout(layout)
    @_content_for[:layout] = self.output_buffer
    self.output_buffer = render(:file => "layouts/#{layout}")
  end

  def flash_messages
    raw flash.collect { |key, message| content_tag(:div, message, :id => key) }.join($/)
  end

  def errors_for record
    render :partial => 'shared/form_errors', locals: { record: record }
  end

end
