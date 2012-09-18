require 'spec_helper'

module LocationGrouping

  describe "LocationGrouping" do
    describe "by day" do
      it "has one group on one conversation" do
        location =  a_location("first location") { with_conversation_at( Date.tomorrow, '12-10-2012 12:00') }
        LocationGrouping.by_day([location]).groups.should == [LocationGrouping.a_day_group(Date.tomorrow, [location])]
      end

      it "has two groups on two locations with a location on different days"  do
        location =  a_location("first location") { with_conversation_at( Date.today, '12-10-2012 12:00') }
        location2 = a_location("second location") { with_conversation_at(Date.tomorrow, '12-10-2012 16:00') }
        LocationGrouping.by_day([location, location2]).groups.should == [
          LocationGrouping.a_day_group(Date.today, [location]),
          LocationGrouping.a_day_group(Date.tomorrow, [location2])
        ]
      end

      it "has two groups on one location with two conversations on differrent days"  do
        location =  a_location("first location") { with_conversation_at( Date.today, '12-10-2012 12:00'); and_conversation_at(Date.tomorrow, '12-10-2012 16:00') }
        LocationGrouping.by_day([location]).groups.should == [
          LocationGrouping.a_day_group(Date.today, [location]),
          LocationGrouping.a_day_group(Date.tomorrow, [location])
        ]
      end

      it "always sorts the days ascending"  do
        location =  a_location("first location") { with_conversation_at( Date.tomorrow, '12-10-2012 12:00'); and_conversation_at(Date.today, '12-10-2012 16:00') }
        LocationGrouping.by_day([location]).groups.should == [
          LocationGrouping.a_day_group(Date.today, [location]),
          LocationGrouping.a_day_group(Date.tomorrow, [location])
        ]
      end
    end

    describe "by day part" do
      it "has one group in the morning for one conversation" do
        location =  a_location("first location") { with_conversation_at( Date.tomorrow, '12-10-2012 11:59') }
        LocationGrouping.by_day_part([location]).groups.should == [LocationGrouping.a_morning_group(Date.tomorrow, [location])]
      end

      it "has one group in the afteroon on one conversation if time is in the afternoon" do
        location =  a_location("first location") { with_conversation_at( Date.tomorrow, '12-10-2012 12:00') }
        LocationGrouping.by_day_part([location]).groups.should == [LocationGrouping.an_afternoon_group(Date.tomorrow, [location])]
      end

      it "has one group in the evening on one conversation if time is in the in the evening" do
        location =  a_location("first location") { with_conversation_at( Date.tomorrow, '12-10-2012 18:00') }
        LocationGrouping.by_day_part([location]).groups.should == [LocationGrouping.an_evening_group(Date.tomorrow, [location])]
      end

      it "has two groups on two locations with a location on different dayparts"  do
        location =  a_location("first location") { with_conversation_at( Date.tomorrow, '12-10-2012 11:00') }
        location2 = a_location("second location") { with_conversation_at(Date.tomorrow, '12-10-2012 16:00') }
        LocationGrouping.by_day_part([location, location2]).groups.should == [
          LocationGrouping.a_morning_group(Date.tomorrow, [location]),
          LocationGrouping.an_afternoon_group(Date.tomorrow, [location2])
        ]
      end

      it "has two groups on two locations with a location on different days"  do
        location =  a_location("first location") { with_conversation_at( Date.today, '12-10-2012 11:00') }
        location2 = a_location("second location") { with_conversation_at(Date.tomorrow, '12-10-2012 16:00') }
        LocationGrouping.by_day_part([location, location2]).groups.should == [
          LocationGrouping.a_morning_group(Date.today, [location]),
          LocationGrouping.an_afternoon_group(Date.tomorrow, [location2])
        ]
      end

      it "has two groups on one locations with two conversations on different dayparts"  do
        location =  a_location("first location") { 
          with_conversation_at( Date.tomorrow, '12-10-2012 11:00')
          and_conversation_at(Date.tomorrow, '12-10-2012 16:00') 
        }
        LocationGrouping.by_day_part([location]).groups.should == [
          LocationGrouping.a_morning_group(Date.tomorrow, [location]),
          LocationGrouping.an_afternoon_group(Date.tomorrow, [location])
        ]
      end

      it "always sorts the days ascending"  do
        location =  a_location("first location") { 
          with_conversation_at(Date.today, '12-10-2012 16:00') 
          and_conversation_at(Date.today, '12-10-2012 11:59')
        }
        LocationGrouping.by_day_part([location]).groups.should == [
          LocationGrouping.a_morning_group(Date.today, [location]),
          LocationGrouping.an_afternoon_group(Date.today, [location])
        ]
      end

      describe "iterating" do
        it "iterates over groups and locations" do
          location =  a_location("first location") { 
            with_conversation_at(Date.today, '12-10-2012 16:00') 
            and_conversation_at(Date.today, '12-10-2012 11:59')
          }
          location2 = a_location("second location") { 
            with_conversation_at(Date.tomorrow, '12-10-2012 11:00')
          }

          result = []
          LocationGrouping.by_day_part([location, location2]).each_group do |group|
            result << group.description
            group.each_location do |location|
              result << location.name
            end
          end

          result.should == [LocationGrouping.a_morning_group(Date.today).description, location.name,
                            LocationGrouping.an_afternoon_group(Date.today).description, location.name,
                            LocationGrouping.a_morning_group(Date.tomorrow).description, location2.name]
        end
      end
      
    end

    describe "none" do
      it "has one group in the morning for one conversation" do
        location1 =  a_location("first location") { with_conversation_at( Date.tomorrow, '12-10-2012 11:59'); and_conversation_at(Date.today, '12-10-2012 11:59') }
        location2 =  a_location("first location") { with_conversation_at( Date.tomorrow, '12-10-2012 11:59') }
        LocationGrouping.none([location1, location2]).groups.should == [LocationGrouping.an_all_group([location1,location2])]
      end

    end


    describe LocationGroup do
      describe "descriptions" do
        it "DayGroup should contain the date" do
          DayGroup.new(Date.today).describe.should == I18n.l(Date.today, format: :long)
        end
        it "AllGroup should contain the date" do
          AllGroup.new(Date.today).describe.should == ''
        end
        it "DayPartGroups should contain date and parts" do
          MorningGroup.new(Date.today).describe.should == I18n.l(Date.today, format: :long) + ' ' + I18n.t('location_grouping.morning_group')
          AfternoonGroup.new(Date.today).describe.should == I18n.l(Date.today, format: :long) + ' ' + I18n.t('location_grouping.afternoon_group')
          EveningGroup.new(Date.today).describe.should == I18n.l(Date.today, format: :long) + ' ' + I18n.t('location_grouping.evening_group')
        end
        describe "with tag" do
          it "wraps it in a tag" do
            DayGroup.new(Date.today).describe("h3").should == "<h3>#{I18n.l(Date.today, format: :long)}</h3>"
          end
        end
      end
    end



    class LocationBuilder
      def initialize(name, &block)
        @location = Location.new(name: name)
        @block = block
      end
      def build
        instance_eval(&@block) if @block
        @location
      end
      def with_conversation_at(date, time)
        @location.conversations << Conversation.new(start_date: date, start_time:time)
      end
      alias_method :and_conversation_at, :with_conversation_at
    end
    def a_location(name, &block)
      LocationBuilder.new(name, &block).build
    end
  end

end
