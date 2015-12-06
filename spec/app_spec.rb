require_relative 'spec_helper'
require 'page-object'
require 'json'

describe 'Bueze UI Testing' do
  include PageObject::PageFactory

  before do
    unless @browser
      @headless = Headless.new
      @browser = Watir::Browser.new
    end
    @browser.goto 'localhost:9292'
  end

  describe 'Visiting the home page' do
    it 'finds the title' do
      @browser.title.must_equal 'Bueze'
    end
  end

  describe 'Visiting the find user page' do
    it 'can go to the find user page' do
      visit HomePage do |page|
        page.click_find_user
        @browser.url.must_match %r{http.*/user}
        @browser.text_field(name: 'user_id').exists?.must_equal true
      end
    end

    it 'can search the user with user id' do
      visit UserPage do |page|
        page.find_user('12522728')
        @browser.url.must_match %r{http.*/user/12522728}
        page.shown_user_id.must_equal '12522728'
        page.num_of_books_shown.must_equal 41
      end
    end
  end
end
