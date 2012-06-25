module NotificationsHelper
  def markup(text)
    raw BlueCloth.new(text).to_html
  end
end
