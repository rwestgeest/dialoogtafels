module ModelFilter
  class Filter
    attr_reader :name
    def initialize(model, name, method)
      @model = model
      @method = method
      @name = name
    end
    def call(*args)
      @model.send(@method, *args)
    end
    def self.null(model, name = '')
      NullFilter.new(model, name, nil)
    end
  end

  class NullFilter < Filter
    def call(*args) 
      @model
    end
  end

  class FilterDefiner
    def initialize(host)
      @host = host
    end
    def all
      @host.add_filter(:all, Filter.null(@host, :all))
    end
    def method_missing(filter, method_name)
      @host.add_filter(filter, Filter.new(@host, filter, method_name))
    end
  end

  module ClassMethods
    def define_filters(&block)
      FilterDefiner.new(self).instance_eval(&block)
    end
    def filter(filter_name)
      filter_name = filter_name.to_sym if filter_name
      defined_filters[filter_name] 
    end
    def add_filter(filter_name, filter)
      defined_filters.default = filter if defined_filters.empty?
      defined_filters[filter_name] = filter
      filters << filter
    end
    def filters
      @filters ||= []
    end
    private
    def defined_filters
      @@defined_filters ||= {}
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
  end
end
