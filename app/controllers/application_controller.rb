class ApplicationController < ActionController::Base
  protect_from_forgery
  prepend_before_filter :set_current_tenant
  helper_method :current_account

  protected
  def sign_in(account)
    session[:current_account_id] = account.to_param
  end
  def sign_out
    session[:current_account_id] = nil
  end
  def current_account
    @current_account ||= Account.find(current_account_id)
  end
  def current_organizer
    current_account.active_contribution
  end
  def current_account_id
    session[:current_account_id]
  end

  def set_current_tenant
    Tenant.current = Tenant.find_by_url_code subdomain
  end
  def subdomain
    return 'test' unless request.host.include?('.')
    request.host.split('.').first
  end
end
