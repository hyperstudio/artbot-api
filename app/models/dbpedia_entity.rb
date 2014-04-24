class DbpediaEntity < ActiveRecord::Base
    # has_and_belongs_to_many :dbpedia_entities,
    #     class_name: "DbpediaEntity",
    #     join_table: :dbpedia_relationships,
    #     foreign_key: :dbpedia_category_id,
    #     association_foreign_key: :dbpedia_entity_id
end