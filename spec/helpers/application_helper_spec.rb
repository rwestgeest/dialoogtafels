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
end
