require 'spec_helper'

describe Organizer do
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

    describe "first landing page" do
      let(:organizer) { FactoryGirl.create :organizer }
      subject { organizer }
      its(:first_landing_page) { should == '/organizer/locations/new' }
      context "when account is coordinator" do
        before { organizer.account.update_attribute :role, Account::Coordinator }
        its(:first_landing_page) { should == "/city/locations/new?organizer_id=#{organizer.id}" }
      end
    end

    describe "creating a organizer" do
      context "when organizer exists" do
        let!(:existing_organizer) { FactoryGirl.create :organizer } 
        it "fails" do 
          new_organizer = Organizer.new(:email => existing_organizer.email)
          new_organizer.should_not be_valid
          new_organizer.errors[:email].should include(I18n.t('activerecord.errors.models.organizer.attributes.email.existing'))
        end
      end
    end
  end
end
