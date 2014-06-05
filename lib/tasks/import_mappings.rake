namespace :map do
    task :csv => :environment do
        obj = csv_file_to_obj(os.environ.get('ALL_GENRES'))
        process_incoming_mapping_hash(obj)
    end
    task :json => :environment do
        admin_mapper = AdminMapper.new
        obj = admin_mapper.json_file_to_obj('dbpedia.json')
        admin_mapper.process_incoming_mapping_hash(obj)
    end
end