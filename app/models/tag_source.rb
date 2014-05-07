class TagSource < ActiveRecord::Base
  validates :name, presence: true
  acts_as_tagger

end
