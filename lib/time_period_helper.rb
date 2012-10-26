module TimePeriodHelper
  def time_period(object)
    string  = "op #{ I18n.l(object.start_date) } van #{ I18n.l(object.start_time) } tot "
    string << "#{ I18n.l(object.end_date) } om " if object.start_date != object.end_date
    string + "#{ I18n.l(object.end_time) }"
  end
end

