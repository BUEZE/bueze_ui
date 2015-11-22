require 'taaze'
require 'json'

##
# Loads and returns full book info
#
# Example:
#   book = BookInfo.new('11100763252')
#   puts book.to_json
#
class BookInfo
  attr_reader :product_id, :tags

  def initialize(product_id)
    @product_id = product_id
    @tags = load_tags
  end

  def to_json
    { 'product_id' => @product_id, 'tags' => @tags }.to_json
  end

  def load_tags
    Taaze::TaazeBooktags.new(@product_id).tags
  end
end
