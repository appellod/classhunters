class AddIndexToSchoolsName < ActiveRecord::Migration
  def change
  	add_index :schools, :name, unique: true
  end
end
