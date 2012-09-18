# this is used to group locations by day or day part
module LocationGrouping
  ValidStrategies = %w{none by_day by_day_part} 
  class <<self
    def by_day(locations)
      DayGrouper.new(locations)
    end
    def by_day_part(locations)
      DayPartGrouper.new(locations)
    end
    def none(locations)
      NoGrouper.new(locations)
    end
    def group_by(strategy, locations)
      ValidStrategies.include?(strategy.to_s) && self.send(strategy, locations) || none(locations)
    end
    def a_day_group(date, locations = [])
      DayGroup.new(date, locations)
    end
    def an_all_group(locations = [])
      AllGroup.new(locations)
    end
    def a_morning_group(date, locations = [])
      MorningGroup.new(date, locations)
    end
    def an_afternoon_group(date, locations = [])
      AfternoonGroup.new(date, locations)
    end
    def an_evening_group(date, locations = [])
      EveningGroup.new(date, locations)
    end
  end

  class LocationGrouper
    attr_reader :locations
    def initialize(locations)
      @locations = locations
      @current_group = NullGroup.new
    end

    def groups
      @groups ||= create_groups
    end

    def each_group(&block)
      groups.each(&block)
    end

    def inspect
      "a #{grouper_type} for #{locations.collect {|l|l.name}}"
    end

    def ==(other)
      other.class == self.class && locations == other.locations
    end

    def empty?
      groups.empty?
    end


    private 
    attr_reader :current_group
    def create_groups
      @groups = []
      sorted(conversations).each do |conversation|
        unless current_group.may_hold(conversation)
          create_group(conversation) 
        end
        current_group.add_location conversation.location
      end 
      @groups
    end

    def grouper_type
      self.class.to_s
    end

    def conversations
      @locations.collect {|location| location.conversations}.flatten
    end
    def create_group(conversation)
      @groups << @current_group = new_group_instance(conversation)
    end
  end

  class DayGrouper < LocationGrouper
    def sorted(conversations)
      conversations.sort{|x,y| x.start_date <=>  y.start_date} 
    end

    def new_group_instance(conversation)
      DayGroup.new(conversation.start_date)
    end
  end

  class DayPartGrouper < LocationGrouper
    def sorted(conversations)
      conversations.sort{|x,y| x.start_time  <=>  y.start_time} 
    end

    def new_group_instance(conversation)
      return MorningGroup.new(conversation.start_date) if MorningGroup.should_contain(conversation)
      return AfternoonGroup.new(conversation.start_date) if AfternoonGroup.should_contain(conversation)
      return EveningGroup.new(conversation.start_date)
    end
  end

  class NoGrouper < LocationGrouper
    attr_reader :groups
    def initialize(locations)
      @locations = locations
      @groups = [ AllGroup.new(locations) ]
    end
  end


  class LocationGroup
    attr_reader :date, :locations

    def initialize(date, locations = [])
      @date = date
      @locations = locations
    end

    def add_location(location)
      locations << location
    end

    def each_location(&block)
      locations.each(&block)
    end

    def ==(other)
      return false if self.class != other.class 
      other.date == date && other.locations == locations
    end

    def inspect
      "a #{group_type} on #{@date.inspect} with #{@locations.collect{|l| l.name}}"
    end

    def description(format = :long)
      I18n.l(date, format: format)
    end

    def describe(tag=nil)
      tag && describe_in(tag) || description
    end

    def describe_in(tag)
      "<#{tag}>#{description}</#{tag}>"
    end

    def group_type
      self.class.to_s.underscore
    end
  end

  class NullGroup
    def may_hold(conversation)
      false
    end
  end

  class AllGroup < LocationGroup
    def initialize(locations)
      @locations = locations
    end
    def describe(tag=nil)
      ''
    end
    def inspect
      "a #{group_type} with #{@locations.collect{|l| l.name}}"
    end
  end

  class DayGroup < LocationGroup
    def may_hold(conversation)
      conversation.start_date == date
    end
  end

  class DayPartGroup < LocationGroup
    def may_hold(conversation)
      conversation.start_date == date && self.class.should_contain(conversation)
    end
    def description 
      super + ' ' + I18n.t(group_type.sub('/', '.'))
    end
  end

  class MorningGroup < DayPartGroup
    def self.should_contain(conversation)
      conversation.start_time.hour < 12
    end
  end

  class AfternoonGroup < DayPartGroup
    def self.should_contain(conversation)
      conversation.start_time.hour < 18
    end
  end

  class EveningGroup < DayPartGroup
    def self.should_contain(conversation)
      true
    end
  end

end

