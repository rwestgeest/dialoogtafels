class Notifications < ActionMailer::Base
  default from: lambda {Tenant.current.from_email} 

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.account_reset.subject
  #
  def account_reset(account)
    @account = account
    mail to: account.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.account_welcome.subject
  #
  def account_welcome(account)
    @account = account
    mail to: account.email
  end
end
