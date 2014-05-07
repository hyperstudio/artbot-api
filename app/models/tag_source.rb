class TagSource < ActiveRecord::Base
  validates :name, presence: true
  acts_as_tagger

  def self.dbpedia
    find_or_create_by(name: 'DBpedia')
  end
end
