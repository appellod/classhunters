class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :name
      t.string :description
      t.string :department
      t.integer :number

      t.timestamps
    end
  end
end
