module City::TodosHelper
  def progress_image(progress, element_id)
    content_tag :span, "#{progress} %", :id => element_id, :class => :progress_indicator, :style => "background:url('/assets/progress.png') no-repeat scroll -#{(100 - progress)/2}px top;"
  end
end
