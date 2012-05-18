class Notifications < ActionMailer::Base

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.account_reset.subject
  #
  def account_reset(account)
    @account = account
    mail from: account.tenant.from_email, to: account.email
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.notifications.account_welcome.subject
  #
  def account_welcome(account)
    @account = account
    mail from:account.tenant.from_email, to: account.email
  end
end
