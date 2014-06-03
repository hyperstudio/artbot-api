namespace :map do
    task :admin => :environment do
        arr_of_arrs = CsvParser.new.read('infile.csv')
        # Array of arrays must be an array with second row and beyond starting
        # ['CATEGORY_NAME', 'CATEGORY_URL', 'ENTITY_NAME', 'ENTITY_URL']
        headers = arr_of_arrs.shift
        for arr in arr_of_arrs
            # AdminMapper args: name, url, tags, source_name
            admin_mapper_args = [arr[2], arr[3], [arr[0]]]
            AdminMapper.new(*admin_mapper_args).link_to_events
        end
    end
end