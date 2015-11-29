require_relative 'spec_helper'
require 'json'

describe 'Bueze UI Testing' do
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
      @browser.link(text: 'Find User').click

      @browser.url.must_match %r{http.*/user}
      @browser.text_field(name: 'user_id').exists?.must_equal true
    end

    it 'can search the user with user id' do
      @browser.link(text: 'Find User').click

      @browser.text_field(name: 'user_id').set('12522728')
      @browser.button(id: 'home-form-submit').click
      
      @browser.url.must_match %r{http.*/user/12522728}
      @browser.h3.text.must_equal '12522728'
      @browser.table(class: 'table').exist?.must_equal true
      @browser.table(class: 'table').rows[0][0].text.must_equal '#'
      @browser.table(class: 'table').rows[0][1].text.must_equal 'Title'
    end
  end
end
