class AdminMapper
    ADMIN_SOURCE = TagSource.admin

    def json_file_to_obj(filepath)
        json_file = nil
        File.open(path, 'r') do |f|
            json_file = JsonRequester.new.load(f, false)
        end
        json_file
    end

    def csv_file_to_obj(rows_or_filepath)
        """
        Rows should be [GENRE_NAME, URL_1, URL_2, etc. etc.] (e.g. from a CSV)
        Converts the urls to json paths, e.g. 'artsy.net/gene/abstract-expressionism' will look for '/artsy/abstract-expressionism.json'
        """
        if rows_or_filepath.respond_to?(:to_s)
            rows_or_filepath = CsvParser.new.read(rows)
        end
        rows = rows_or_filepath
        final_mappings = {}
        row_length = rows.empty? ? 0 : rows.first
        rows.each do |row|
            genre_name = row.shift
            row.select {|u| !u.empty?}.each do |url|
                final_mappings[genre_name][url] = get_entities_from_json(url)
            end
        end
    end

    def get_entities_from_json(url)
        """
        Used to import genres/tags from external sources.
        Example: get_entities_from_json('http://artsy.net/gene/abstract-expressionism') will look for a file called '/artsy/abstract-expressionism.json'
        It will important parse 
        """
        folder_path = url.split('/')[2].split('.')[0]
        genre_slug = url.split('/').pop
        json_file = json_file_to_obj('%s/%s.json' % [folder_path, genre_slug])
        json_file[:results][:collection1].map {|entity| process_entity(entity)}
    end

    def process_entity(entity, folder_path)
        if folder_path == 'artsy'
            result = {
                :name => entity[:related_artists][:text],
                :url => entity[:related_artists][:href]
            }
        elsif folder_path == 'the-artists'
            result = {
                :name => flip_name(entity[:artist_name][:text]), 
                :url => entity[:artist_name][:href]
            }
        end
        result
    end

    def flip_name(name)
        split_name = name.split(', ')
        name = "%s %s" % [split_name[1], split_name[0]] if split_name.count > 1
        name.strip
    end

    ### Methods for processing once the info has been ingested in a hash obj.

    def process_incoming_mapping_hash(hash_obj)
        hash_obj.map do |admin_tag, url_hash|
            puts "On %s" % admin_tag
            url_hash.map do |url, entity_list|
                puts "...URL %s" % url
                # save_and_relate_entity(admin_tag, url, [admin_tag], "", admin_source)
                entity_list.each do |entity|
                    entity.symbolize_keys!
                    save_and_relate_entity(entity[:name], entity[:url], [admin_tag], "person", ADMIN_SOURCE)
                end
            end
        end
    end

    def save_and_relate_entity(name, url, tags, entity_type, source)
        # Cut out any trailing parens from dbpedia
        name = name.include?("(") ? name.split("(")[0].strip : name
        new_tag = {
            :name => name,
            :url => url,
            :tags => tags,
            :entity_type => entity_type,
            :source => source
        }
        puts "...creating new entity %s" % new_tag
        entity = EntityCreator.new(new_tag, true, true).entity
        entity.matching_entity_events.map {|event| entity.add_event(event)}
    end
end