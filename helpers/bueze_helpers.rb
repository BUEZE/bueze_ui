# Helpers for main sinarta web application
module BuezeHelpers
  def get_userinfo(user_id)
    UserInfo.new(user_id)
  rescue
    halt 404
  end

  def get_collections(user_id)
    UserCollections.new(user_id)
  rescue
    halt 404
  end

  def get_comments(user_id)
    UserComments.new(user_id)
  rescue
    halt 404
  end

  def get_tags(product_id)
    BookInfo.new(product_id)
  rescue
    halt 404
  end
end
