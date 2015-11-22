require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
require 'slim'

# Simple web service for taaze api
class AppController < Sinatra::Base
  helpers ApplicationHelpers 
  register Sinatra::Flash
  use Rack::MethodOverride

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure :production, :development do
    enable :logging
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
   
    logger.info "http://bueze.herokuapp.com/api/v1/user/#{@user_id}" 
    begin
      @userinfo = HTTParty.get bueze_api_url("user/#{@user_id}")
    logger.info @userinfo + 'QQ!'
    rescue
      flash[:notice] = 'Could not access Bueze - please try again later'
      logger.info "GG"
    end

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
