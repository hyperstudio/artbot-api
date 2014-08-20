class AdminMapper
  ## This needs some love after many refactors

  ADMIN_SOURCE = TagSource.admin
  @result = nil

  def json_from_path(filepath, symbolize_keys: false)
    json_file = nil
    File.open(filepath, 'r') do |f|
      json_file = JsonRequester.new.load(f, symbolize_keys)
    end
    @result = json_file
  end

  def json_from_file_obj(file)
    @result = JsonRequester.new.load(file, false)
  end

  def csv_to_json(rows_or_filepath, outfile)
    # Rows should be [GENRE_NAME, URL_1, URL_2, etc. etc.] (e.g. from a CSV)
    # Converts the urls to json paths, e.g.
    # 'artsy.net/gene/abstract-expressionism' will look for
    # '/artsy/abstract-expressionism.json'

    unless rows_or_filepath.respond_to?(:to_ary)
      rows_or_filepath = CsvParser.new.read(rows_or_filepath)
    end
    rows = rows_or_filepath
    final_mappings = {}
    rows.each do |row|
      genre_name = row.shift
      final_mappings[genre_name] = {}
      row.select {|u| !u.empty?}.each do |url|
        final_mappings[genre_name][url] = get_entities_from_json(url, :by_file => true)
      end
    end
    JsonRequester.new.dump(final_mappings, outfile)
  end

  def get_entities_from_json(url, by_file: false)
    # Used to import genres/tags from external sources.
    # Example:
    # get_entities_from_json('http://artsy.net/gene/abstract-expressionism')
    # will look for a file called '/artsy/abstract-expressionism.json' It will
    # important parse 

    folder_path = url.split('/')[2].split('.')[0]
    genre_slug = url.split('/').pop
    if by_file
      json_file = json_from_path('%s/%s.json' % [folder_path, genre_slug], :symbolize_keys => true)
    else
      json_file = JsonRequester.new.get(url)
    end
    json_file[:results][:collection1].map {|entity| process_entity(entity, folder_path)}
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

  def process_result
    if @result.present?
      @result.map do |admin_tag, url_hash|
        url_hash.map do |url, entity_list|
          entity_list.each do |entity|
            entity.symbolize_keys!
            save_and_relate_entity(entity[:name], entity[:url], [admin_tag], "person", ADMIN_SOURCE)
          end
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
    entity = EntityCreator.new(new_tag, true, true).entity
    entity.matching_entity_events.map {|event| entity.add_event(event)}
  end
end
