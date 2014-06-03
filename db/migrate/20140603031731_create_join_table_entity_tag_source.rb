class CreateJoinTableEntityTagSource < ActiveRecord::Migration
  def change
    create_join_table :entities, :tag_sources do |t|
      t.index [:entity_id, :tag_source_id]
      t.index [:tag_source_id, :entity_id]
    end
  end
end
