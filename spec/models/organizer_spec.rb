require 'spec_helper'

describe Organizer, :focus => true do
  describe 'validations' do
    prepare_scope :tenant
    let(:existing_organizer) { FactoryGirl.create :organizer } 
    it { should validate_presence_of :email }
    it { should validate_presence_of :name }
    it { should validate_presence_of :person }
    ["rob@", "@mo.nl", "123.nl", "123@nl", "aaa.123.nl", "aaa.123@nl"].each do |illegal_mail|
      it { should_not allow_value(illegal_mail).for(:email) }
    end
  end

  it_should_behave_like 'a_scoped_object', :organizer

  context "with current tenant" do
    prepare_scope :tenant

    it_should_behave_like "creating_a_contributor", Organizer do
      def create_contributor(extra_attributes = {}) 
        FactoryGirl.create :organizer, extra_attributes
      end
    end
  end
end
