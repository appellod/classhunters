class CreateSemesters < ActiveRecord::Migration
  def change
    create_table :semesters do |t|
      t.string :name
      t.integer :year
      t.integer :position

      t.timestamps
    end
  end
end
