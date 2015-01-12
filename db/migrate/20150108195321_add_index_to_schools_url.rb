class AddIndexToSchoolsUrl < ActiveRecord::Migration
  def change
  	add_index :schools, :url, unique: true
  end
end
