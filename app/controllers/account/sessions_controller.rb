class Account::SessionsController < ApplicationController
  layout 'sessions'
  def new
    @account = Account.new
    @account.email = params[:email]
    @maintainer_login = params[:maintainer] && true || false
    @for = params[:for]
  end

  def create
    if @account = authenticate_by_email_and_password
      sign_in @account
      if for_url
        redirect_to for_url
      else
        redirect_to @account.landing_page
      end
    else
      flash.alert = 'e-mail of wachtwoord incorrect' 
      @account = Account.new
      render :action => 'new'
    end
  end

  def destroy
    sign_out
    redirect_to root_path
  end

  private 

  def authenticate_by_email_and_password
    if maintainer_login
      @account = MaintainerAccount.authenticate_by_email_and_password(account_params[:email], account_params[:password])
    else
      @account = TenantAccount.authenticate_by_email_and_password(account_params[:email], account_params[:password])
    end
  end

  def maintainer_login
    @maintainer_login ||= params[:maintainer] && true || false
  end
  def for_url
    @for ||= params[:for]
  end

  def account_params
    params[:account]
  end
end
