class TagContext < ActiveRecord::Base
    validate :name_must_be_lowercase, 
             :name_must_be_pluralized, 
             :name_cant_have_whitespace
    validates :name, uniqueness: true

    def self.default
        movement
    end

    def self.movement
        find_or_create_by(name: 'movements')
    end

    def self.era
        find_or_create_by(name: 'eras')
    end

    def self.region
        find_or_create_by(name: 'regions')
    end

    def self.all_names
        pluck('name')
    end

    private

    def name_must_be_lowercase
        if self.name != self.name.downcase
            errors.add(:name, "must be lowercase")
        end
    end

    def name_must_be_pluralized
        if self.name != self.name.pluralize
            errors.add(:name, "must be pluralized")
        end
    end

    def name_cant_have_whitespace
        if self.name.match(/\s/)
            errors.add(:name, "can't have whitespace")
        end
    end
end