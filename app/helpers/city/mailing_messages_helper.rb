module City::MailingMessagesHelper
  include ::MessagesHelper

  def parent_reference(comment, form)
     form.hidden_field(:parent_id) if comment
  end

  def render_mailing_message(mailing_message)
    render partial: 'mailing_message', locals: { mailing_message: mailing_message }
  end

  def new_mailing_message_form(parent_message)
    render :partial => 'new_mailing_message_form', locals: { parent_message: parent_message }
  end
end
