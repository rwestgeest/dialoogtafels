class Account::SessionsController < ApplicationController
  layout 'sessions'
  def new
    @account = Account.new
    @account.email = params[:email]
    @maintainer_login = params[:maintainer] && true || false
  end

  def create
    if params[:maintainer]
      @account = MaintainerAccount.authenticate_by_email_and_password(account_params[:email], account_params[:password])
      @maintainer_login = true 
    else
      @account = TenantAccount.authenticate_by_email_and_password(account_params[:email], account_params[:password])
    end
    if @account 
      sign_in @account
      redirect_to @account.landing_page
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

  def account_params
    params[:account]
  end
end
