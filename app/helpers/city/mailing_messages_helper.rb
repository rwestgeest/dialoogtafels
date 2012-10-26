module City::MailingMessagesHelper
  include ::MessagesHelper

  def parent_reference(comment, form)
     form.hidden_field(:parent_id) if comment
  end

  def render_mailing_message(mailing_message)
    render partial: 'mailing_message', locals: { mailing_message: mailing_message }
  end

  def new_mailing_message_form(message)
    render :partial => 'new_mailing_message_form', locals: { mailing_message: message }
  end

  def addressee_group_names(message)
    message.groups.empty? && t('nobody') || message.groups.map{ |group| t(group) }.join(', ')
  end
end
