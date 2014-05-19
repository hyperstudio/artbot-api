class Entity < ActiveRecord::Base
  acts_as_taggable_on :genres
  has_and_belongs_to_many :events
end
