module City::LocationsHelper
  def aspect_link(path, link, *args)
    if (selection_path request.parameters) =~ /^#{path}/
      return content_tag :span, link, :class => "selected-text"
    end
    link_to link, *args
  end
  def selection_path(request_params)
    result = request_params['controller']
    result += "#"+ request_params['action'] unless request_params['action'] == 'index'
    result
  end
end
