class ApplicationController < ActionController::Base
  protect_from_forgery
  prepend_before_filter :authorize_action
  prepend_before_filter :set_current_tenant
  helper_method :current_account, :current_person, :current_tenant, :active_project, :signed_in?

  protected
  def authorized?(account, request)
    ActionGuard.authorized?(account, request)
  end

  def authorize_action
    unless authorized?(current_account, request)
      flash[:alert] = I18n.t('not_authorized')
      sign_out
      redirect_to '/'
    end
  end

  def sign_in(account)
    session[:current_account_id] = account.to_param
  end

  def sign_out
    session[:current_account_id] = nil
    @current_account = nil
  end

  def current_account
    @current_account ||= Account.find(current_account_id) rescue nil
  end

  def current_person
    current_account.person
  end

  def signed_in?
    current_account != nil
  end

  def current_organizer
    current_account.highest_contribution
  end

  def current_conversation_leader
    current_account.highest_contribution
  end

  def current_account_id
    session[:current_account_id]
  end

  def current_tenant
    Tenant.current
  end

  def active_project
    current_tenant.active_project
  end

  def set_current_tenant
    Tenant.current = Tenant.find_by_host full_host
  end

  def full_host
    return 'test.host' unless request.host.include?('.')
    request.host
  end
end
