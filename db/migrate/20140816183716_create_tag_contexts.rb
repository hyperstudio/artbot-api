class CreateTagContexts < ActiveRecord::Migration
  def change
    create_table :tag_contexts do |t|
        t.string :name
    end
  end
end
