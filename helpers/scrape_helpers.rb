# Helpers for main sinarta web application
module ScrapeHelpers

  def get_ranking(source)
    BookRankingList.new(source).ranking
  rescue
    halt 404
  end

end
