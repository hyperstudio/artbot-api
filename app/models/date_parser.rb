require 'chronic'

class DateParser
    SPLITTERS = ['-', '–', ' to ', ' | ', 'through']
    FLAGS = ['on view', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']

    def self.parse(daterange)
        start_date, end_date = [nil] * 2
        SPLITTERS.each do |splitter|
            date_split = daterange.split(splitter)
            date_split.each_with_index do |date, index|
                FLAGS.each do |flag|
                    if date.downcase.start_with?(flag)
                        date = date[flag.length..-1]
                    end
                end
                parsed_date = Chronic.parse(date)
                unless parsed_date.nil?
                    if start_date.nil? and index == 0
                        start_date = parsed_date
                    elsif end_date.nil? and index == 1
                        end_date = parsed_date
                    end
                end
            end
        end
        unless (start_date == nil || end_date ==  nil)
            now = Time.now
            if start_date == end_date
                end_date = nil
            elsif [end_date.year, end_date.month, end_date.day] == [now.year, now.month, now.day]
                end_date = Time.new(start_date.year, start_date.month, start_date.day, end_date.hour, end_date.min, end_date.sec)
            elsif start_date > end_date
                years_ago = start_date.year - end_date.year
                start_date = start_date.ago(years_ago.year)
            end
        end
        [start_date, end_date]
    end
end