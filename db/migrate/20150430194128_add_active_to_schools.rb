class AddActiveToSchools < ActiveRecord::Migration
  def change
  	add_column :schools, :active, :boolean, null: false, default: false
  end
end
