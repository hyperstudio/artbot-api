class TagSource < ActiveRecord::Base
  validates :name, presence: true
  acts_as_tagger

  def self.dbpedia
    find_or_create_by(name: 'DBpedia')
  end

  def self.calais
    find_or_create_by(name: 'OpenCalais')
  end
end
