module Settings::ProjectsHelper
  def strategies_for_select
    LocationGrouping::ValidStrategies.collect {|strategy| [I18n.t("location_grouping.strategies.#{strategy}"), strategy]}
  end
  def cc_types_for_select
    ProjectMailer::ValidTypes.collect {|cc_type| [I18n.t("settings.project.mailer.types.#{cc_type}"), cc_type]} 
  end
end
