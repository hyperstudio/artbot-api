class AddPriceToLocation < ActiveRecord::Migration
  def change
  	add_column :locations, :price, :text, default: ''
  end
end
