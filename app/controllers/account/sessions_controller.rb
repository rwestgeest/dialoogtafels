class Account::SessionsController < ApplicationController

  def new
    @account = Account.new
  end

  def create
    @account = Account.authenticate_by_email_and_password(account_params[:email], account_params[:password])
    if @account 
      sign_in @account
      redirect_to @account.landing_page
    else
      flash.alert = 'e-mail of wachtwoord incorrect' 
      @account = Account.new
      render :action => 'new'
    end
  end

  private 

  def account_params
    @account_params ||= params[:account]
  end
end
