require 'net/http'
class Maakum
  MailingPath = "/mailing/"
  attr_reader :site_url
  def initialize(url)
    @site_url = url
  end
  def has_mailing?
    begin
      res = Net::HTTP.get(mailing_url)
      return res[/form.*\/mailing\//] && res[/input.*name.*name/] && res[/input.*name.*email/] && true || false
    rescue
      return false
    end
  end
  def register_for_mailing(name, email)
    begin
      Net::HTTP.post_form(mailing_url, :name => name, :email => email)
    rescue
      return false
    end
  end
  def ==(other)
    other.is_a?(Maakum) && site_url == other.site_url 
  end
  def inspect
    "Maakum(#{ site_url })"
  end
  private
  def mailing_url
    URI.parse([site_url, MailingPath].join('/'))
  end
end
