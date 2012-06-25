class Postman
  def self.deliver(message, *args)
    Notifications.send(message, *args).deliver
  end
  def self.schedule_message_notification(message, addressee)
    Notifications.send(:new_comment, message, addressee).deliver
  end
end

