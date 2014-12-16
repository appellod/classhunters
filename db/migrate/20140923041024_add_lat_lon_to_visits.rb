class AddLatLonToVisits < ActiveRecord::Migration
  def change
  	add_column :visits, :latitude, :decimal
  	add_column :visits, :longitude, :decimal
  end
end
