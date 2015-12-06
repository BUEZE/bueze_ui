require 'page-object'

# User Page Object
class UserPage
  include PageObject

  page_url 'http://localhost:9292/user'

  text_field(:user_id_input, id: 'home-form-userid')
  button(:find_user_button, id: 'home-form-submit')
  h3(:shown_user_id)
  table(:result_table, class: 'table')

  def num_of_books_shown
    result_table_element.rows - 1
  end

  def find_user(user_id)
    self.user_id_input = user_id
    find_user_button
  end
end
