class AddCityStateZipToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :city, :string
  	add_column :schools, :state, :string
  	add_column :schools, :zip, :string
  end
end
