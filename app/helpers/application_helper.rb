require 'menu'
require 'time_period_helper'

module ApplicationHelper
  include TimePeriodHelper
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

  def guarded_link_to(what, url_options, html_options = nil)
    return '' unless ActionGuard.authorized?(current_account, url_options.stringify_keys)
    link_to(what, url_options, html_options)
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

  def tenant_styles
    if current_tenant.has_public_style_sheet?
      stylesheet_link_tag current_tenant.public_style_sheet, :media => "all" 
    end
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


  def tenant_site_url
    Tenant.current.site_url
  end

  def published(location)
    return '' if location.published 
    raw(link_to '(concept)', edit_city_location_publication_path(location_id:  location.id), 
                                    :title => 'Deze locatie is nog niet zichtbaar op te site, wijzig publicatiedetails om te publiceren')
  end

  def registered_at(object)
    if object.created_at
      t('registered_at', time: l(object.created_at, format: :date))
    else
      'weet niet'
    end
  end

  def registered_as(object)
    t('as') + ' ' + t(object.type_name)
  end

  def location_submenu
    page_side_bar 'city/locations/location_side_bar'
  end

  def participant_registration(conversation, *args)
    return nil if conversation.participants_full?
    link_to *args
  end

  def leader_registration(conversation, *args)
    return nil if conversation.leaders_full?
    link_to *args
  end
  
  def select_person_link(person, path, selected_person)
    if person == selected_person
      link_to person.name, path, :remote => true
    else
      link_to person.name, path, :remote => true
    end
  end

  def person_link_attributes(person, selected_person)
    attrs = {id:"person_#{person.to_param}"}
    person == selected_person && attrs.merge(class: "selected") || attrs
  end

  def aspect_link(path, link, *args)
    if (selection_path request.parameters) =~ /^#{path}/
      return content_tag :span, link, :class => "selected-text"
    end
    link_to link, *args
  end

  def top_background_image
    current_tenant.top_image
  end
  def right_background_image
    current_tenant.right_image
  end

  def training_registration_tags training_types, attendee, dont_register_message
    render( partial: 'shared/training_registration_tags', collection: training_types, :as => :training_type, locals: { attendee: attendee, dont_register_message: dont_register_message })
  end

  private
  def selection_path(request_params)
    result = request_params['controller']
    result += "#"+ request_params['action'] unless request_params['action'] == 'index'
    result
  end
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

  def recaptcha_error_flash_tag(message)
    return '' if message != 'recaptcha-not-reachable'
    flash_tag(:recaptcha_error, I18n.t(message))
  end

  def created_at(object)
    return '' unless object.created_at
    "Aangemaakt: " + l(object.created_at, :format => :human)
  end

  def updated_at(object)
    return '' unless object.updated_at
    "Bijgewerkt: " + l(object.updated_at, :format => :human)
  end
 
  def flash_tag(name, message)
    content_tag :div, image_tag("#{name}.png") + content_tag(:span, message), :id => "#{name}", :class => "flash"
  end


end
