require 'csv'

class CsvParser

    def read(path)
        CSV.read(path)
    end

    def write(path, data, headers=nil)
        CSV.open(path, 'w+') do |csv|
            csv << headers if headers.present?
            data.each {|row| csv << row}
        end
    end
end