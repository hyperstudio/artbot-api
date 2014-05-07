class CreateTagSources < ActiveRecord::Migration
  def change
    create_table :tag_sources do |t|
      t.string :name
    end
  end
end
