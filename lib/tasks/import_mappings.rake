namespace :map do
    task :csv => :environment do
        rows = CsvParser.read('infile.csv')
        AdminMapper.new.csv_to_json(rows, 'outfile.json')
    end
    task :json => :environment do
        admin_mapper = AdminMapper.new
        obj = admin_mapper.json_from_path('infile.json')
        admin_mapper.process_incoming_mapping_hash(obj)
    end
end