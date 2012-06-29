require 'spec_helper'

describe Training  do
  it_should_behave_like 'a_scoped_object', :training
  it { should validate_presence_of :name }
  it { should validate_presence_of :location }
  it { should validate_presence_of :max_participants }
  it { should validate_numericality_of :max_participants }
  it { should validate_presence_of :start_date }
  it { should validate_presence_of :start_time }
  it { should validate_presence_of :end_date }
  it { should validate_presence_of :end_time }

  context "with tenant scope" do
    prepare_scope :tenant


    describe "setting start date and start time_" do
      it_should_behave_like "schedulable", :start_date, :start_time do
        def create_schedulable(attrs = {}) 
          Training.new(attrs)
        end
      end
    end

    describe "setting end date and end time_" do
      it_should_behave_like "schedulable", :end_date, :end_time do
        def create_schedulable(attrs = {}) 
          Training.new(attrs)
        end
      end
    end

    describe "creating a training" do
      it "associates it for the tenants active project" do
        FactoryGirl.create :training 
        Training.last.project.should == Tenant.current.active_project
      end
    end

    describe "sending an invitation", :focus => true do
      let(:attendee) { FactoryGirl.create :person }
      let(:training) { FactoryGirl.create :training }
      before { attendee.register_for(training) }

      subject { training }

      context "before sending" do
        it {should_not have_invited(attendee)}
      end 

      context "after sending" do
        let(:author) { FactoryGirl.create(:person) }
        before { create_messaage_from(author, [attendee.id]) }
        it { should have_invited(attendee) }
        it { should_not have_invited(author) }
      end 

      def create_messaage_from(author, addressee_id_list = [], parent_comment = nil)
        comment = FactoryGirl.build(:training_invitation, :subject => "subject", :reference_id => training.id, :author => author, :parent => parent_comment)
        comment.set_addressees(addressee_id_list)
        comment.save!
        comment
      end
    end

  end

end
