require 'spec_helper'

describe Project do
  describe 'validation' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :conversation_length }
    it { should validate_numericality_of :conversation_length }
    it { should validate_presence_of :max_participants_per_table }
    it { should validate_numericality_of :max_participants_per_table }
    it { should validate_presence_of :tenant }
    it { should validate_presence_of :organizer_confirmation_subject }
    it { should validate_presence_of :participant_confirmation_subject }
    it { should validate_presence_of :conversation_leader_confirmation_subject }
    it { should ensure_inclusion_of(:grouping_strategy).in_array(LocationGrouping::ValidStrategies) }
  end

  it_should_behave_like 'a_scoped_object', :project

  context "with tenant scope" do
    describe "defaults" do 
      subject { Project.new }
      its(:start_time) { should be_within(1).of(Time.now) }
    end

    describe "setting start date and start time_" do
      it_should_behave_like "schedulable", :start_date, :start_time do
        def create_schedulable(attrs = {}) 
          Project.new(attrs)
        end
      end
    end

  end

  describe "mailer" do
    it "is an aggregation of cc_type and cc_address_list" do
      an_email_copy_list('bcc', 'rob@email.com').should == ProjectMailer.new('bcc', 'rob@email.com')
    end

    describe "mailer" do
      let(:cc_address_list) { 'some_cc@mail.com' } 
      let(:cc_type) { ProjectMailer::NoCcList } 
      let(:cc_mailer) { Project.new(cc_type: cc_type, cc_address_list: cc_address_list).mailer_on(mailer) }
      let(:mailer) { mock('Mailer') }

      it "sends the mail to the receient" do
        mailer.should_receive(:mail).with(to: 'some@mail.com')
        cc_mailer.mail(to: 'some@mail.com')
      end

      context "when cc_type is cc" do
        let(:cc_type) { ProjectMailer::CcList } 

        it "puts addresses in cc list" do
          mailer.should_receive(:mail).with hash_including(cc: 'some_cc@mail.com')
          cc_mailer.mail(to: 'some@mail.com')
        end

        context "with more email addresses separated by comma" do
          let(:cc_address_list) { "one@mail.com, two@mail.com" }
          it "puts all addresses in bcc list" do
            mailer.should_receive(:mail).with hash_including(cc: ['one@mail.com', 'two@mail.com'])
            cc_mailer.mail(to: 'some@mail.com')
          end
        end
      end

      context "when cc_type is bcc" do
        let(:cc_type) { ProjectMailer::BccList } 
        it "puts addresses in bcc list" do
          mailer.should_receive(:mail).with hash_including(bcc: 'some_cc@mail.com')
          cc_mailer.mail(to: 'some@mail.com')
        end

        context "with more email addresses separated by comma" do
          let(:cc_address_list) { "one@mail.com, two@mail.com" }
          it "puts all addresses in bcc list" do
            mailer.should_receive(:mail).with hash_including(bcc: ['one@mail.com', 'two@mail.com'])
            cc_mailer.mail(to: 'some@mail.com')
          end
        end
      end

    end

    def an_email_copy_list(cc_type, cc_address_list)
      Project.new(cc_type: cc_type, cc_address_list: cc_address_list).mailer
    end
  end


end
