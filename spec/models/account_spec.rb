require 'spec_helper'

describe Account, :focus => true  do
  describe "new"  do
    it "can be created without password" do
      expect { 
        a = Account.new FactoryGirl.attributes_for(:new_account)
        p a 
        a.save
        p a.errors

      }.to change(Account, :count).by 1
    end

  end
end
