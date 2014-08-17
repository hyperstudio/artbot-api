class TagContext < ActiveRecord::Base

    def self.insensitive_find(path)
        where("lower(name) = ?", path.downcase).first
    end

    def self.genre
        find_or_create_by(name: 'genre')
    end

    def self.movement
        find_or_create_by(name: 'movement')
    end
end