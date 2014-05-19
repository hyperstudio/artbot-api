class RenameRefCountOnDbpediaEntity < ActiveRecord::Migration
  def change
    rename_column :dbpedia_entities, :refCount, :refcount
  end
end
