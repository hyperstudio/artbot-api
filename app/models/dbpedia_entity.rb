class DbpediaEntity < ActiveRecord::Base
  validates :name, presence: true

  acts_as_taggable_on :genre
  has_and_belongs_to_many :events
  # has_and_belongs_to_many :dbpedia_entities,
  #     class_name: "DbpediaEntity",
  #     join_table: :dbpedia_relationships,
  #     foreign_key: :dbpedia_category_id,
  #     association_foreign_key: :dbpedia_entity_id
end
