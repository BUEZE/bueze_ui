ENV['RACK_ENV'] = 'test'

Dir.glob('./{helpers,controllers,forms,services}/*.rb').each { |file| require file }
Dir.glob('./spec/pages/*.rb').each { |file| require file }
require 'minitest/autorun'
require 'rack/test'
require 'watir-webdriver'
require 'headless'
require 'page-object'

include Rack::Test::Methods

def app
  AppController
end
