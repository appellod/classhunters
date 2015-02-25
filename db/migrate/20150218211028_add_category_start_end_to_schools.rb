class AddCategoryStartEndToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :category, :string
  	add_column :schools, :start_date, :date
  	add_column :schools, :end_date, :date
  end
end
