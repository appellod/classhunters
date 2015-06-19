class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
      t.string :status
      t.integer :crn
      t.string :location
      t.boolean :online, null: false, default: false
      t.boolean :sunday, null: false, default: false
      t.boolean :monday, null: false, default: false
      t.boolean :tuesday, null: false, default: false
      t.boolean :wednesday, null: false, default: false
      t.boolean :thursday, null: false, default: false
      t.boolean :friday, null: false, default: false
      t.boolean :saturday, null: false, default: false
      t.time :start_time
      t.time :end_time
      t.date :start_date
      t.date :end_date
      t.string :faculty
      t.integer :available
      t.integer :capacity
      t.integer :waitlist
      t.decimal :credits
      t.string :academic_level
      t.references :semester, index: true
      t.references :course, index: true

      t.timestamps
    end
  end
end
