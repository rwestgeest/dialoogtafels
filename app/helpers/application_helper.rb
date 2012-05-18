module ApplicationHelper
  def title(title)
    content_for(:title) { title }
  end

  def login_information
    return '' unless current_account
    raw "logged in: #{h(current_account.email)}(#{h(current_account.role)}) " +  
    "| #{link_to('logout', account_session_path, :method => :delete )}" +
    "| #{link_to('wachtwoord wijzigen', edit_account_password_path)}"
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

  def flash_tags
    raw(flash.collect do |name, message| 
      flash[name] = nil
      self.send("#{name}_flash_tag", message) if message
    end.join)
  end

  def errors_for record
    render :partial => 'shared/form_errors', locals: { record: record }
  end

  def destroy_link(path, text_representation)
    raw  link_to('verwijderen', path, :title => 'verwijderen', :confirm => 'Weet u zeker dat u deze #{text_representation} wilt verwijderen?', :method => :delete)
  end

  private
  def alert_flash_tag(message)
    flash_tag(:alert, message)
  end

  def notice_flash_tag(message)
    flash_tag(:notice, message) + raw(%Q{
      <script type="text/javascript">
        $('#notice').delay(10000).fadeOut('slow');
      </script>
    })
  end

  def flash_tag(name, message)
    content_tag :div, image_tag("#{name}.png") + message, :id => "#{name}", :class => "flash"
  end


end
