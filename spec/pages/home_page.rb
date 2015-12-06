require 'page-object'

# Home Page Object
class HomePage
  include PageObject

  page_url 'http://localhost:9292'

  link(:find_user_link, id: 'user')

  def click_find_user
    find_user_link
  end
end
