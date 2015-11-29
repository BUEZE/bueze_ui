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
  end
end
