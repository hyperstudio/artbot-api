require 'net/http'
require 'multi_json'

sample_url = "http://artx.apiary.io/events"

namespace :scrape do
    desc 'run scrapers for museum websites'
    task :runscraper do
        # run scraper here
        url = URI.parse(sample_url)
        req = Net::HTTP::Get.new(url.path)
        req['accept'] = 'application/json'
        res = Net::HTTP.start(url.host, url.port) {|http|
            http.request(req)
        }
        results = MultiJson.load(res.body)
        return results
    end
end
