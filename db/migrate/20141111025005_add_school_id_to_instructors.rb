class AddSchoolIdToInstructors < ActiveRecord::Migration
  def change
  	add_reference :instructors, :school, index: true
  end
end
