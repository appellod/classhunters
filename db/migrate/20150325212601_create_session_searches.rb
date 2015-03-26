class CreateSessionSearches < ActiveRecord::Migration
  def change
    create_table :session_searches do |t|
      t.text :search
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.string :ip_address
      t.boolean :sunday
      t.boolean :monday
      t.boolean :tuesday
      t.boolean :wednesday
      t.boolean :thursday
      t.boolean :friday
      t.boolean :saturday
      t.time :start_time
      t.time :end_time
      t.boolean :classroom
      t.boolean :online
      t.references :school, index: true
      t.references :user, index: true

      t.timestamps
    end
  end
end
