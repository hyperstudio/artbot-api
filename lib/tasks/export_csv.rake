namespace :csv do
    task :export_entities => :environment do
        rows = []
        headers = ['ID', 'URL', 'NAME', 'ENTITY_TYPE', 'TYPE_GROUP', 'SCORE', 'GENRES', 'SOURCES', 'EVENTS']
        Entity.all.find_each do |entity|
            rows.push([
                entity.id, 
                entity.url, 
                entity.name, 
                entity.entity_type, 
                entity.type_group, 
                entity.score, 
                entity.tag_list, 
                entity.source_list, 
                entity.event_list
                ])
        end
        csv_string = CsvParser.new.write_to_string(rows, headers)
        puts csv_string
        csv_string
    end
end