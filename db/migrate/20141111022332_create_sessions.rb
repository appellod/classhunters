class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.boolean :sunday
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.time :start_time
      t.time :end_time
      t.references :course, index: true
      t.references :instructor, index: true

      t.timestamps
    end
  end
end
