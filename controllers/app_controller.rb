require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
require 'slim'

# Simle web service for taaze api
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

  get_user = lambda do
    content_type :json, charset: 'utf-8'
    get_userinfo(params[:user_id]).to_json
  end

  get_user_collections = lambda do
    content_type :json, charset: 'utf-8'
    get_collections(params[:user_id]).to_json
  end

  get_user_comments = lambda do
    content_type :json, charset: 'utf-8'
    get_comments(params[:user_id]).to_json
  end

  get_product_tags = lambda do
    content_type :json, charset: 'utf-8'
    get_tags(params[:product_id]).to_json
  end

  # Post bookrank JSON data and save to database
  post_bookranking = lambda do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
      halt 400
    end

    rankinglist = get_ranking(req['source'])

    flag = true
    rankinglist.each do |book|
      bookranking = Bookranking.new(
        booknames: book['booknames'].to_json,
        rank: book['rank'].to_json,
        price: book['price'].to_json,
        price_description: book['price_description'].to_json,
        author: book['author'].to_json,
        date: book['date'].to_json,
        prod_id: book['prod_id'].to_json,
        source: book['source'].to_json)
      flag = false unless bookranking.save
    end

    if flag
      status 201
      redirect "/api/v1/bookranking/#{rankinglist[0]['date']}", 303
    else
      halt 500, 'Some error occured when '\
                'saving bookranking request to the database'
    end
  end

  # Get the data at index
  get_bookranking = lambda do
    content_type :json, charset: 'utf-8'
    begin
      p bookranking = Bookranking.where(date: Date.parse(params[:date]))
      logger.info(bookranking.to_json)
    rescue
      halt 400
    end

    bookranking.to_json
  end

  # Web API Routes
  get '/api/v1/user/:user_id', &get_user
  get '/api/v1/collections/:user_id.json', &get_user_collections
  get '/api/v1/comments/:user_id.json', &get_user_comments
  get '/api/v1/tags/:product_id.json', &get_product_tags
  get '/api/v1/bookranking/:date', &get_bookranking
  post '/api/v1/bookranking', &post_bookranking
  post '/api/v1/bookranking/', &post_bookranking

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
