class Postman
  def self.deliver(message, *args)
    Notifications.send(message, *args).deliver
  end
  def self.schedule_message_notification(message, addressee)

  end
end

