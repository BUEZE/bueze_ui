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

  app_get_book = lambda do
    @books_name = params[:books_name]

    if @books_name
      redirect "/booksearch/#{@books_name}"
      return nil
    end

    slim :home
  end

  app_get_books = lambda do
    @books_name = params[:books_name]

    logger.info "Search book : #{@books_name}"
    begin
      @book_search_result = HTTParty.get URI.encode(bueze_api_url("search_book/#{@books_name}"))
      if @book_search_result == null
        @book_search_result = [1]
        redirect '/'
        return nil
      end
      @search_length = @book_search_result.length.to_s

    rescue
      flash[:notice] = 'Could not access Bueze - please try again later'
      logger.info 'Could not access the site'
      flash[:notice] = 'Books not found' if @books_name.nil?
      redirect '/'
      return nil
    end
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
      @history_ranking = Hash.new{ 11 }
      @history_rankings = HTTParty.get URI.encode(bueze_api_url("get_bookhistory/#{@name}"))
      startdate = Date.parse(@history_rankings[0]['date'].to_s)
      (startdate..Date.today).each do |date|
        @history_ranking[date.to_s] = 11
        @history_rankings.each do |ranking|
          @history_ranking[ranking['date']] = ranking['rank'] if date.to_s == ranking['date']
        end
      end
    rescue
      flash[:notice] = 'Could not access Bueze - please try again later'
      logger.info 'Could not access the site'
    end
    @history_ranking.to_json
  end

  app_get_bookinfo = lambda do
    begin
      content_type :json, charset: 'utf-8'
      @name = params[:name]
      @tags = HTTParty.get URI.encode(bueze_api_url("search_book_tags/#{@name}"))
    rescue
      flash[:notice] = 'Could not access Bueze - please try again later'
      logger.info 'Could not access the site'
    end
    {'tags': @tags}.to_json
  end

  app_get_dailyrankinglist = lambda do
    begin
      @date = Date.parse(params[:date].to_s)
      @ranking = HTTParty.get bueze_api_url("bookranking/#{@date.prev_day}")
      slim @date == Date.today ? :home : :daily_ranking_list
    rescue
      flash[:notice] = 'Could not check daily ranking list, please check later'
      logger.info 'Could not access the site'
    end
  end

  app_get_weeklyrankinglist = lambda do
    begin
      ranking_of_week = []
      @startdate = Date.parse(params[:daterange].split('&')[0].to_s).prev_day
      @enddate = Date.parse(params[:daterange].split('&')[1].to_s).prev_day
      week_range = (@startdate..@enddate)
      week_range.each do |date|
        day_ranking = HTTParty.get bueze_api_url("bookranking/#{date}")
        ranking_of_week << day_ranking
      end

      week_ranking_hash = Hash.new { 0 }
      ranking_of_week.each do |dailylist|
        dailylist.each do |book|
          week_ranking_hash[book['booknames']] += (11 - book['rank'])
        end
      end

      week_ranking = week_ranking_hash.sort_by { |k, v| v }.reverse
      result = []
      week_ranking.each_with_index do |book, index|
        break if index > 9
        found_book = false
        ranking_of_week.each do |dailylist|
          break if found_book == true
          JSON.parse(dailylist.to_json).each do |daily_book|
            if daily_book['booknames'] == book[0]
              new_book = daily_book
              new_book['rank'] = index + 1
              result << new_book
              found_book = true
              break
            end
          end
        end
      end
      @ranking = result
      slim :weekly_ranking_list
    rescue
      flash[:notice] = 'Could not check daily ranking list, please check later'
      logger.info 'Could not access the site'
    end
  end

  app_get_monthlyrankinglist = lambda do
    begin
      ranking_of_week = []
      @startdate = Date.parse(params[:daterange].split('&')[0].to_s).prev_day
      @enddate = Date.parse(params[:daterange].split('&')[1].to_s).prev_day
      week_range = (@startdate..@enddate)
      week_range.each do |date|
        day_ranking = HTTParty.get bueze_api_url("bookranking/#{date}")
        ranking_of_week << day_ranking
      end

      week_ranking_hash = Hash.new { 0 }
      ranking_of_week.each do |dailylist|
        dailylist.each do |book|
          week_ranking_hash[book['booknames']] += (11 - book['rank'])
        end
      end

      week_ranking = week_ranking_hash.sort_by { |k, v| v }.reverse
      result = []
      week_ranking.each_with_index do |book, index|
        break if index > 9
        found_book = false
        ranking_of_week.each do |dailylist|
          break if found_book == true
          JSON.parse(dailylist.to_json).each do |daily_book|
            if daily_book['booknames'] == book[0]
              new_book = daily_book
              new_book['rank'] = index + 1
              result << new_book
              found_book = true
              break
            end
          end
        end
      end
      @ranking = result
      slim :monthly_ranking_list
    rescue
      flash[:notice] = 'Could not check daily ranking list, please check later'
      logger.info 'Could not access the site'
    end
  end

  # Web App Views Routes
  get '/', &app_get_root
  get '/user', &app_get_user
  get '/booksearch', &app_get_book
  get '/booksearch/:books_name', &app_get_books
  get '/bookinfo', &app_get_bookinfo
  get '/user/:user_id', &app_get_userinfo
  get '/user_chart/:user_id', &app_get_userchart
  get '/ranking_chart', &app_get_rankingchart
  get '/daily_ranking_list/:date', &app_get_dailyrankinglist
  get '/weekly_ranking_list/:daterange', &app_get_weeklyrankinglist
  get '/monthly_ranking_list/:daterange', &app_get_monthlyrankinglist
end
