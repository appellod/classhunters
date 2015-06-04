class AddAttributesToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :description, :text
  	add_column :schools, :founding_date, :string
  end
end
