class ChangeSchoolsLatLonToBiggerDecimals < ActiveRecord::Migration
  def change
  	change_column :schools, :latitude, :decimal, :precision => 15, :scale => 10
  	change_column :schools, :longitude, :decimal, :precision => 15, :scale => 10
  end
end
