require 'spec_helper'

describe ApplicationHelper do
  include ApplicationHelper
  describe "time_period" do
    let(:today) { Date.today }
    let(:now)  { Time.now } 
    let(:an_hour_from_now) { now + 1.hour }
    let(:conversation ) { Conversation.new :start_date => today, :start_time => now, :end_date => today, :end_time => an_hour_from_now }

    it "contains the date and times when dates are the same" do
      time_period(conversation).should =~ /.*#{ I18n.l(today) }.*#{ I18n.l(now) }[^0-9]*#{ I18n.l(an_hour_from_now) }$/
    end

    it "contains the dates and times when dates are different same" do
      conversation.end_date = Date.tomorrow
      time_period(conversation).should =~ /.*#{ I18n.l(today) }.*#{ I18n.l(now) }.*#{I18n.l(Date.tomorrow)}.*#{ I18n.l(an_hour_from_now) }$/
    end
  end
  
  describe "registration links" do
    def link_to *args
      "link_to #{args.join(', ')}"
    end

    describe 'participant_registration' do
      let(:conversation) { stub(Conversation, :participants_full? => false) } 
      it 'is rendered wen location has room for participants' do
        participant_registration(conversation, 'text' ,'options').should == 'link_to text, options'
      end
      it 'is not rendered wen location has no room for participants' do
        conversation.stub(:participants_full? => true)
        participant_registration(conversation, 'text' ,'options').should be_nil
      end
    end
    describe 'leader_registration' do
      let(:conversation) { stub(Conversation, :leaders_full? => false) }
      it 'is rendered wen location has room for leaders' do
        leader_registration(conversation, 'text' ,'options').should == 'link_to text, options'
      end
      it 'is not rendered wen location has no room for leaders' do
        conversation.stub(:leaders_full? => true)
        leader_registration(conversation, 'text' ,'options').should be_nil
      end
    end
  end
  include Menu::RequestParams
  describe 'aspect_link' do
    def link_to(*args) 
      "the_link"
    end
    def request
      stub(:parameters => @current_request_params)
    end
    it "renders link " do
      @current_request_params = request_params_for("city/locations#show")
      aspect_link("city/locations#edit", "link_name").should == "the_link"
    end
    it "renders selected text if path matches" do
      @current_request_params = request_params_for("city/locations#show")
      aspect_link("city/locations#show", "link_name").should == "<span class=\"selected-text\">link_name</span>"
    end
    it "renders selected text if path matche partially" do
      @current_request_params = request_params_for("city/locations#show")
      aspect_link("city/locations", "link_name").should == "<span class=\"selected-text\">link_name</span>"
    end
  end
end
