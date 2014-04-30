require 'net/http'
require 'multi_json'

scraper_app_url = "http://localhost:7000"
ner_app_url = "http://localhost:5000"

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
    endpoint = ner_app_url + "/stanford"
    post_data = {:payload => payload}
    categories = json_request(endpoint, 'POST', post_data)
    return categories
end

def query_scraper_app(path)
    endpoint = scraper_app_url + "/" + path
    events = json_request(endpoint, 'GET', {})
    return events
end

def save_entity(ner_result)
    dbpedia_entity = DbpediaEntities.find_or_initialize_by(url: ner_result["uri"])
    dbpedia_entity.name = ner_result["label"]
    dbpedia_entity.description = ner_result["description"]
    dbpedia_entity.refCount = ner_result["refCount"]
    dbpedia_entity.save
    ner_result["categories"].each do |c|
        category_entity = DbpediaEntities.find_or_initialize_by(url: c['uri'])
        category_entity.name = c["label"]
        # I don't think this works because it would replace all other relationships...
        category_entity.dbpedia_entity_id = dbpedia_entity.id
        category.save
    end
    return dbpedia_entity
end

namespace :scrape do
    desc 'run scrapers and entity recognition for museum websites'
    task :runscraper do
        ScraperUrl.each do |u|
            # This is where we query the scraper app
            results = query_scraper_app(u.name)
            results.each do |r|
                stripped_url = strip_query_params_from_url(r["url"])
                event = Event.find_or_initialize_by(stripped_url)
                if event.new_record?
                    # This is where we query the NER app
                    payload = r["name"] + " " + r["description"]
                    entities = query_ner_app(payload)
                    linked_entities = []
                    entities.each do |e|
                        unless e["uri"].nil?
                            saved_entity = save_entity(e)
                            linked_entities.push(saved_entity)
                        end
                    end
                    event.name = r["name"],
                    event.url => stripped_url,
                    event.description => r["description"],
                    event.location_id => u["location_id"],
                    event.image => r["image"],
                    event.dbpedia_entities => linked_entities)
                    event.save
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