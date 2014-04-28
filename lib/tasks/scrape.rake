require 'net/http'
require 'multi_json'

scraper_app_url = "http://localhost:8000"
ner_app_url = "http://localhost:5000"

def json_request(endpoint, method, data)
    url = URI.parse(endpoint)
    if method == 'GET'
        req = Net::HTTP::Get.new(url.path)
        url.query = URI.encode_www_form(data)
    else
        req = Net::HTTP::Post.new(url.path)
        req.set_form_data(data)
    end
    req['accept'] = 'application/json'
    res = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
    }
    return MultiJson.load(res.body)
end

def query_ner_app(payload)
    endpoint = ner_app_url + "/stanford"
    post_data = {:payload => payload}
    categories = json_request(endpoint, 'POST', post_data)
    return categories
end

def query_scraper_app(event_index_url)
    endpoint = scraper_app_url
    query_params = {:url => event_index_url}
    events = json_request(endpoint, 'GET', query_params)
    return events
end

namespace :scrape do
    desc 'run scrapers for museum websites'
    task :runscraper do
        all_event_urls = Event.pluck('url')
        ScraperUrl.each do |u|
            # This is where we query the scraper app
            results = query_scraper_app(u.url)
            results.each do |r|
                unless all_event_urls.include? u.url
                    # This is where we query the NER app
                    payload = r.name + " " + r.description
                    categories = query_ner_app(payload)
                    Event.create(
                        :name => r.name,
                        :description => r.description,
                        :location_id => u.location_id,
                        :image => r.image,
                        :dbpedia_entities => categories)
                end
            end
        end
    end
end