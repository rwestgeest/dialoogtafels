class Account::PasswordsController < ApplicationController
  def edit
    @account = current_account
  end
  def update
    @account = current_account
    if @account.confirm_with_password(params[:account]) 
      redirect_to @account.landing_page
    else
      render :action => :edit
    end
  end
end
