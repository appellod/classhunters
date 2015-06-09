class CreateCourseSearches < ActiveRecord::Migration
  def change
    create_table :course_searches do |t|
      t.text :search
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.string :ip_address
      t.references :school, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
