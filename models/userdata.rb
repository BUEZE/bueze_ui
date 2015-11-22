require 'taaze'
require 'json'

##
# Loads and returns full user info
#
# Example:
#   user_info = UserInfo.new('12522728')
#   puts user_info.to_json
#
module TaazeLoader
  def load_collections
    Taaze::TaazeCollections.new(@user_id).collections
  end

  def load_comments
    Taaze::TaazeComments.new(@user_id).comments
  end
end

# UserInfo
class UserInfo
  attr_reader :user_id, :collections, :comments
  include TaazeLoader

  def initialize(user_id)
    @user_id = user_id
    @collections = load_collections
    @comments = load_comments
  end

  def to_json
    { 'user_id' => @user_id, 'collections' => @collections, 'comments' => @comments }.to_json
  end
end

##
# Loads and returns full user collections
#
# Example:
#   user_collections = UserCollections.new('12522728')
#   puts user_collections.to_json
#
class UserCollections
  attr_reader :user_id, :collections
  include TaazeLoader

  def initialize(user_id)
    @user_id = user_id
    @collections = load_collections
  end

  def to_json
    { 'user_id' => @user_id, 'collections' => @collections }.to_json
  end
end

##
# Loads and returns full user comments
#
# Example:
#   user_comments = UserComments.new('12522728')
#   puts user_comments.to_json
#
class UserComments
  attr_reader :user_id, :comments
  include TaazeLoader

  def initialize(user_id)
    @user_id = user_id
    @comments = load_comments
  end

  def to_json
    { 'user_id' => @user_id, 'comments' => @comments }.to_json
  end
end
