require 'addressable/uri'

module ApplicationHelpers

  API_BASE_URI = 'http://bueze.herokuapp.com'
  API_VER = '/api/v1/'

  def current_page?(path = ' ')
    path_info = request.path_info
    path_info += ' ' if path_info == '/'
    request_path = path_info.split '/'
    request_path[1] == path
  end

  def bueze_api_url(resource)
    Addressable::URI.join(API_BASE_URI, API_VER, resource).to_s
  end

end
