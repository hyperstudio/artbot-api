require 'net/http'
require 'multi_json'

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
    ner_app_url = "http://localhost:5000"
    endpoint = ner_app_url + "/stanford"
    post_data = {:payload => payload}
    categories = json_request(endpoint, 'POST', post_data)
    return categories
end

def query_scraper_app(path)
    scraper_app_url = "http://localhost:7000"
    endpoint = scraper_app_url + "/" + path
    events = json_request(endpoint, 'GET', {})
    return events
end

def save_entity(ner_result)
    dbpedia_entity = DbpediaEntity.find_or_initialize_by(url: ner_result["uri"])
    dbpedia_entity.name = ner_result["label"]
    dbpedia_entity.description = ner_result["description"]
    dbpedia_entity.refCount = ner_result["refCount"]
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

def filter_and_save_entities(entities)
    linked_entities = []
    ["PERSON", "LOCATION", "ORGANIZATION"].each do |type|
        entities[type].each do |e|
            unless e["uri"].nil?
                saved_entity = save_entity(e)
                linked_entities.push(saved_entity)
            end
        end
    end
    return linked_entities
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
                    entities = query_ner_app(payload)
                    linked_entities = filter_and_save_entities(entities)
                    event.name = r["name"].strip
                    event.url = stripped_url
                    event.dates = r["dates"].strip
                    event.description = r["description"].strip
                    event.image = r["image"]
                    event.location_id = u["location_id"]
                    event.save
                    event.dbpedia_entities = linked_entities
                else
                    # see if anything has changed about the event
                    changed = false
                    if r["name"] != event.name
                        event.name = r["name"]
                        changed = true
                    end
                    if r["description"] != event.description
                        event.description = r["description"]
                        # should we rerun categorization?
                        changed = true
                    end
                    if r["image"] != event.image
                        event.image = r["image"]
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