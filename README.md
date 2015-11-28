# BUEZE Webservice
[ ![Codeship Status for BUEZE/bueze_ui](https://codeship.com/projects/d034abc0-77da-0133-81e5-0677e176d0b1/status?branch=master)](https://codeship.com/projects/118494)  
Front end of web service Bueze.  
Here's the [link](http://buezeui.herokuapp.com/) to our project.  

### Example:

- Get info of user 12522728 :

	`/user/12522728`

<!--
- Get collections of user 13193872 :

	`/api/v1/user/13193872`

- Get comments of user 13472924 :

	`/api/v1/comments/13472924.json`

- Get tags of book 11100763252 :

	`/api/v1/tags/11100763252.json`

## Database version pre-install

- Install postgres (OS X: `brew install postgres`)

- bundle install

- `rake db:create_migration NAME=create_bookranking` to create your local database

## JSON Post Format
  ```JSON
{
  "booknames": "Chicago love story",
  "rank": 3,
  "price": 689,
  "price_description": 7.9,
  "author": "Hiraku",
  "date": "10-01-1949",
  "source": "USA"
}
  ```
-->
