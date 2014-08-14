# ArtX

Rails 4.1.0, Ruby 2.1.1.

To install:

* run `bundle`
* `rake db:setup`
* `rails s`
* Navigate to `localhost:3000` and sign up as a user.
* For admin access, set "admin" attribute to "true" on the user object.

### Data

Sample locations are pre-populated. To start getting live data:

* Install and run [artx-scraper](http://github.com/mailbackwards/artx-scraper)
* Install and run [artx-ner](http://github.com/mailbackwards/artx-ner)
* run `rake scrape:all` (this queries the other apps and populates the database with categorized events)
