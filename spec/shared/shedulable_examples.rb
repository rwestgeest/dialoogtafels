  shared_examples_for "schedulable" do |date_attr, time_attr|
    let(:time) { Time.now }
    let(:date) { Date.tomorrow }

    it "should let start_date override the date_component in start_time when start_time is set first" do
      object = create_schedulable( time_attr => time, date_attr => date)
      object.send(time_attr).should be_within(1.minute).of(time + 1.days)
      object.send(date_attr).should == date
    end

    it "should let start_date override the date_component in start_time when start_date is set first" do
      object = create_schedulable( date_attr => date, time_attr => time)
      object.send(time_attr).should be_within(1.minute).of(time + 1.days)
      object.send(date_attr).should == date
    end

    it "can be done with string values" do
      object = create_schedulable(time_attr => I18n.l(time, :format => :long), date_attr => I18n.l(date))
      object.send(time_attr).should be_within(1.minute).of(time + 1.days)
      object.send(date_attr).should == date
    end

    it "ignores a nil value for date and time" do
      object = create_schedulable date_attr => nil, time_attr => nil
      object.send(date_attr).should == nil
      object.send(time_attr).should == nil
    end

    it "ignores an empty string value for date" do
      object = create_schedulable date_attr => "", time_attr => nil
      object.send(date_attr).should == nil
      object.send(time_attr).should == nil
    end

  end

