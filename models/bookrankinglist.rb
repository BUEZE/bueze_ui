require 'json'
require 'open-uri'
require 'date'

class BookRankingList
  
  # API for Taaze Chinese Rank 10 
  API_URL = 'http://www.taaze.tw/beta/actAllBooksDataAgent.jsp?k=01&t=11&startNum=0&endNum=09&d=00&c=00&a=01&l=0'

  def initialize(source)
    parse_html(source)
  end

  def ranking
    @ranking ||= extract_ranking
  end

  def parse_html(source)
    @doc = JSON.parse(open(API_URL).read)['result1']
  end

  def extract_ranking
    rankings = []
    @doc.each_with_index do |data, i|
      book = {}
      book['booknames'] = data['titleMain']
      book['rank'] = i + 1
      book['price_description'] = data['saleDisc']
      book['price'] = data['salePrice'].to_i
      book['author'] = data['author'] 
      book['date'] = Date.today
      book['source'] = 'taaze'
      book['prod_id'] = data['prodID']
      rankings << book
    end
    rankings
  end
end
