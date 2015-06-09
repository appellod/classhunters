class MoveSemesters < ActiveRecord::Migration
  def change
  	remove_column :sessions, :semester
  	add_column :sessions, :semester_id, :integer
  end
end
