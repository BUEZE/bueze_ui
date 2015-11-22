require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
require 'slim'

# Simple web service for taaze api
class AppController < Sinatra::Base
  helpers BuezeHelpers, ScrapeHelpers
  register Sinatra::Flash
  use Rack::MethodOverride

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure :production, :development do
    enable :logging
  end

  helpers do
    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end
  end

  app_get_root = lambda do
    slim :home
  end

  app_get_user = lambda do
    @user_id = params[:user_id]

    if @user_id
      redirect "/user/#{@user_id}"
      return nil
    end

    slim :user
  end

  app_get_userinfo = lambda do
    @user_id = params[:user_id]
    @userinfo = get_userinfo(@user_id)

    if @user_id && @userinfo.nil?
      flash[:notice] = 'User not found' if @userinfo.nil?
      redirect '/user'
      return nil
    end

    slim :user
  end

  # Web App Views Routes
  get '/', &app_get_root
  get '/user', &app_get_user
  get '/user/:user_id', &app_get_userinfo
end
