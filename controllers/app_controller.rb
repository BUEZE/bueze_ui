require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
require 'slim'
require 'chartkick'
require 'date'

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
    @ranking = HTTParty.get bueze_api_url("bookranking/#{Date.today.prev_day}")
    slim :home
  end

  app_get_user = lambda do
    @user_id = params[:user_id]

    if @user_id
      redirect "/user/#{@user_id}"
      return nil
    end

    slim :user_list
  end

  app_get_books = lambda do
    @books_name = params[:books_name]

    logger.info "Search book : #{@books_name}"
    begin
      @string = ''
      @book_search_result =  [{ 'bookname' => 'hiraku', 'rank' => 10, 'price' => 200, 'ori_price' => 201, 'bookstore' => 'taaze','link' => 'http://www.rubydoc.info/gems/slim/toplevel' },
                              { 'bookname' => 'hiraku', 'rank' => 10, 'price' => 200, 'ori_price' => 199, 'bookstore' => 'booktw','link' => 'http://www.google.tw' }
                              ]
      @search_length = @book_search_result.length.to_s
    rescue
      flash[:notice] = 'Could not access Bueze - please try again later'
      logger.info 'Could not access the site'
    end

    if @books_name && @books_name.nil?
      puts ("bookname: "+@books_name)
      flash[:notice] = 'Books not found' if @books_name.nil?
      redirect '/'
      return nil
    end

    slim :book_search
  end

  app_get_userinfo = lambda do
    @user_id = params[:user_id]
    logger.info "http://bueze.herokuapp.com/api/v1/user/#{@user_id}"
    begin
      @userinfo = HTTParty.get bueze_api_url("user/#{@user_id}")
    # logger.info @userinfo
    rescue
      flash[:notice] = 'Could not access Bueze - please try again later'
      logger.info 'Could not access the site'
    end

    if @user_id && @userinfo.nil?
      flash[:notice] = 'User not found' if @userinfo.nil?
      redirect '/user'
      return nil
    end

    slim :user_list
  end

  app_get_userchart = lambda do
    @user_id = params[:user_id]
    logger.info "http://bueze.herokuapp.com/api/v1/user/#{@user_id}"
    begin
      @string = ''
      @years = Hash['2010' => 0, '2011' => 0, '2012' => 0, '2013' => 0, '2014' => 0, '2015' => 0]
      @userinfo = HTTParty.get bueze_api_url("user/#{@user_id}")
      @userinfo['collections'].each do |book|
        year = book['crt_time'].split('/')[0].to_i
        init_year = 2010
        while init_year <= 2015
          @years[init_year.to_s] += 1 if year <= init_year
          init_year += 1
        end
      end
    rescue
      flash[:notice] = 'Could not access Bueze - please try again later'
      logger.info 'Could not access the site'
    end

    if @user_id && @userinfo.nil?
      flash[:notice] = 'User not found' if @userinfo.nil?
      redirect '/user_chart'
      return nil
    end

    slim :user_chart
  end

  app_get_rankingchart = lambda do
    begin
      content_type :json, charset: 'utf-8'
      @name = params[:name]
      @history_ranking = Hash[]
      @history_rankings = HTTParty.get URI.encode(bueze_api_url("get_bookhistory/#{@name}"))
      @history_rankings.each do |ranking|
        @history_ranking[ranking['date']] = ranking['rank']
      end
    rescue
      flash[:notice] = 'Could not access Bueze - please try again later'
      logger.info 'Could not access the site'
    end
    @history_ranking.to_json
  end

  app_get_dailyrankinglist = lambda do
    begin
      @date = Date.parse(params[:date].to_s)
      @ranking = HTTParty.get bueze_api_url("bookranking/#{@date.prev_day}")
      if @date == Date.today
        slim :home
      else
        slim :daily_ranking_list
      end
    rescue
      flash[:notice] = 'Could not check daily ranking list, please check later'
      logger.info 'Could not access the site'
    end
  end

  # Web App Views Routes
  get '/', &app_get_root
  get '/user', &app_get_user
  get '/books/:books_name', &app_get_books
  get '/user/:user_id', &app_get_userinfo
  get '/user_chart/:user_id', &app_get_userchart
  get '/ranking_chart', &app_get_rankingchart
  get '/daily_ranking_list/:date', &app_get_dailyrankinglist
end
