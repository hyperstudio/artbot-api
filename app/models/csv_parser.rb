require 'csv'

class CsvParser

    def read(path)
        CSV.read(path, encoding: 'ISO8859-1')
    end

    def write(path, data, headers=nil)
        CSV.open('path', 'w+') do |csv|
            data.each do |row|
                csv << row
            end
        end
    end
end