# ArtX

Rails 4.1.0, Ruby 2.1.1.

To install:

* run `bundle`
* `rake db:setup`
* Navigate to `localhost:3000` and sign up as a user.
* For admin access, include [1] in your user's role_ids (either via the console or the admin interface, at /admin)

### Data

To get sample/fixture data:

* run `rake db:seed:20140505_seeds`

Or to start getting live data:

* Install and run [artx-scraper](http://github.com/mailbackwards/artx-scraper)
* Install and run [artx-ner](http://github.com/mailbackwards/artx-ner)
* Add a `Location` and related `ScraperUrl` (see sample seed file for examples)
* run `rake scrape:runscraper` (this queries the other apps and populates the database with categorized events)
