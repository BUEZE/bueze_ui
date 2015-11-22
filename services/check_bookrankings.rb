require 'virtus'
require 'active_model'
##
# Value object for results from searching a tutorial set for missing badges
class BookrankingResult
  include Virtus.model

  attribute :code
  attribute :id

  attribute :booknames
  attribute :rank
  attribute :price_description
  attribute :price
  attribute :author
  attribute :date
  attribute :source
  attribute :prod_id

  attribute :late
  attribute :missing
  attribute :completed

  def to_json
    to_hash.to_json
  end
end

##
# Service object to check tutorial request from API
class CheckBookrankingFromAPI
  def initialize(api_url, form)
    @api_url = api_url
    params = form.attributes.delete_if { |_, value| value.blank? }
    @options = { body: params.to_json,
                 headers: { 'Content-Type' => 'application/json' }
                }
  end

  def call
    results = HTTParty.post(@api_url, @options)
    bookranking_results = BookrankingResult.new(results)
    bookranking_results.code = results.code
    bookranking_results.id = results.request.last_uri.path.split('/').last
    bookranking_results
  end
end
