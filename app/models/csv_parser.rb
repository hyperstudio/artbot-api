require 'csv'

class CsvParser

    def read(path)
        CSV.read(path)
    end

    def add_to_csv(csv_obj, data, headers=nil)
        csv_obj << headers if headers.present?
        data.each {|row| csv_obj << row}
    end

    def write(path, data, headers=nil)
        CSV.open(path, 'w+') do |csv|
            add_to_csv(csv, data, headers)
        end
    end

    def write_to_string(data, headers=nil)
        csv_string = CSV.generate do |csv|
            add_to_csv(csv, data, headers)
        end
        csv_string
    end
end