# Artbot

Rails 4.1.0, Ruby 2.1.2.

To install:

* run `bundle`
* `rake db:setup`
* `rails s`
* Navigate to `localhost:3000/user/sign_up` and sign up as a user.
* For admin access, set `admin` attribute to `true` on the user.

### Data

Sample locations are pre-populated. To start getting live data:

* Install and run [parserbot](http://github.com/mailbackwards/parserbot)
* run `rake scrape:all` (this queries parserbot and populates the database with categorized events)
