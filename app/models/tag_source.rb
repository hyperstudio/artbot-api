class TagSource < ActiveRecord::Base
  validates :name, presence: true
  acts_as_tagger

  def self.stanford
    find_or_create_by(name: 'Stanford')
  end

  def self.dbpedia
    find_or_create_by(name: 'DBpedia')
  end

  def self.calais
    find_or_create_by(name: 'OpenCalais')
  end

  def self.admin
    find_or_create_by(name: 'Admin')
  end
end
