module Settings::ProjectsHelper
  def strategies_for_select
    LocationGrouping::ValidStrategies.collect {|strategy| [I18n.t("location_grouping.strategies.#{strategy}"), strategy]}
  end
end
