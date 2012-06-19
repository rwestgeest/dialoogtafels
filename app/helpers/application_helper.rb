require 'menu'
module ApplicationHelper
  def title(title)
    content_for(:title) { title }
  end

  def context_action(to, path, html_options = {})
    new_link = link_to(t(to), path, html_options)
    return if new_link.empty?
    content_for(:context_actions, " | ") unless content_for(:context_actions).empty?
    content_for(:context_actions, new_link) 
  end

  def login_information
    return '' unless current_account
    raw "logged in: #{h(current_account.email)}(#{h(current_account.role)}) " +  
    "| #{link_to('logout', account_session_path, :method => :delete )}" +
    "| #{link_to('wachtwoord wijzigen', edit_account_password_path)}"
  end

  def menu(request, &block)
    m = Menu.create(self)
    yield(m) 
    raw m.render(request.parameters, current_account)
  end

  def page_info(page_info)
    content_for(:page_info, page_info)
  end

  def page_side_bar(side_bar)
    content_for(:page_side_bar, render(:partial => side_bar))
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

  def full_address(thing)
    raw "#{thing.address} #{thing.city}"
  end

  def person_entry(person)
    person.name
  end

  def markup(text)
    raw BlueCloth.new(text).to_html
  end

  def time_period(object)
    string  = "van #{ I18n.l(object.start_date) } om #{ I18n.l(object.start_time) } tot "
    string << "#{ I18n.l(object.end_date) } om " if object.start_date != object.end_date
    string + "#{ I18n.l(object.end_time) }"
  end

  def tenant_site_url
    Tenant.current.site_url
  end

  def published(location)
    location.published && '' || '(concept)'
  end

  def registered_at(object)
    t('registered_at', time: l(object.created_at, format: :date))
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

  def created_at(object)
    return '' unless object.created_at
    "Aangemaakt: " + l(object.created_at, :format => :short)
  end

  def updated_at(object)
    return '' unless object.updated_at
    "Bijgewerkt: " + l(object.updated_at, :format => :short)
  end
 
  def flash_tag(name, message)
    content_tag :div, image_tag("#{name}.png") + content_tag(:span, message), :id => "#{name}", :class => "flash"
  end


end
