class ChangeSchoolsLatLonToLatitudeLongitude < ActiveRecord::Migration
  def change
  	rename_column :schools, :lat, :latitude
  	rename_column :schools, :lon, :longitude
  end
end
