class TagContext < ActiveRecord::Base
    validates :name, uniqueness: true

    before_validation do
        self.name = self.name.to_s.downcase.pluralize
    end

    DEFAULT_CONTEXT = 'movements'

    def self.default
        find_or_create_by(name: DEFAULT_CONTEXT)
    end

    def self.movement
        find_or_create_by(name: 'movements')
    end

    def self.era
        find_or_create_by(name: 'eras')
    end

    def self.region
        find_or_create_by(name: 'region')
    end

    def self.all_names
        pluck('name')
    end
end