require 'net/http'
require 'multi_json'

SCRAPER_APP_URL = "http://localhost:7000"
NER_APP_URL = "http://localhost:5000"

def strip_query_params_from_url(url)
    # Strips everything after a query param ("?") or hash ("#") in a URL string
    (0..url.length).each do |i|
        if (url[i] == "?" or url[i] == "#")
            url = url[0..i-1]
            break
        end
    end
    return url
end

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
    endpoint = NER_APP_URL + "/stanford"
    post_data = {:payload => payload}
    categories = json_request(endpoint, 'POST', post_data)
    return categories
end

def query_scraper_app(path)
    endpoint = SCRAPER_APP_URL + "/" + path
    events = json_request(endpoint, 'GET', {})
    return events
end

def save_entity(ner_result)
    if ner_result["uri"].nil?
        dbpedia_entity = DbpediaEntity.find_or_initialize_by(stanford_name: ner_result["stanford_name"])
    else
        dbpedia_entity = DbpediaEntity.find_or_initialize_by(url: ner_result["uri"])
    end
    dbpedia_entity.name = ner_result["label"]
    dbpedia_entity.description = ner_result["description"]
    dbpedia_entity.refCount = ner_result["refCount"]
    dbpedia_entity.stanford_name = ner_result["stanford_name"]
    dbpedia_entity.stanford_type = ner_result["stanford_type"]

    # genre_finder = CategoryFinder.new(ner_result['categories'], :genre)
    # dbpedia_entity.genre_list = genre_finder.find_as_tag_list

    dbpedia_entity.save
    # FIGURE THIS OUT LATER
    # ner_result["categories"].each do |c|
    #     category_entity = DbpediaEntity.find_or_initialize_by(url: c['uri'])
    #     category_entity.name = c["label"]
    #     # I don't think this works because it would replace all other relationships...
    #     category_entity.dbpedia_entity_id = dbpedia_entity.id
    #     category.save
    # end
    return dbpedia_entity
end

namespace :scrape do
    desc 'run scrapers and entity recognition for museum websites'
    task :runscraper => :environment do
        ScraperUrl.all.each do |u|
            # This is where we query the scraper app
            results = query_scraper_app(u.name)["results"]
            results.each do |r|
                stripped_url = strip_query_params_from_url(r["url"])
                event = Event.find_or_initialize_by(url: stripped_url)
                if event.new_record?
                    # This is where we query the NER app
                    payload = r["name"] + " " + r["description"]
                    entities = query_ner_app(payload)["results"]
                    saved_entities = entities.map { |e| save_entity(e) }
                    # Now populate attributes for save
                    event.name = r["name"].strip
                    event.url = stripped_url
                    event.dates = r["dates"].strip
                    event.description = r["description"].strip
                    event.image = r["image"]
                    event.location_id = u["location_id"]
                    event.save
                    event.dbpedia_entities = saved_entities
                else
                    # see if anything has changed about the event
                    changed = false
                    if r["name"].strip != event.name
                        event.name = r["name"].strip
                        changed = true
                    end
                    if r["description"].strip != event.description
                        event.description = r["description"].strip
                        payload = r["name"] + " " + r["description"]
                        entities = query_ner_app(payload)["results"]
                        saved_entities = entities.map { |e| save_entity(e) }
                        event.dbpedia_entities = saved_entities
                        changed = true
                    end
                    if r["image"] != event.image
                        event.image = r["image"]
                        changed = true
                    end
                    if r["dates"].strip != event.dates
                        event.dates = r["dates"].strip
                        changed = true
                    end
                    if changed
                        event.save
                    end
                end
            end
        end
    end
end
