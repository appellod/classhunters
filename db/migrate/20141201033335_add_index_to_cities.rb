class AddIndexToCities < ActiveRecord::Migration
  def change
  	add_index :cities, [:zip, :state, :city], unique: true
  end
end
