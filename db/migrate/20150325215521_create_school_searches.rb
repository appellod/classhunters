class CreateSchoolSearches < ActiveRecord::Migration
  def change
    create_table :school_searches do |t|
      t.string :type
      t.string :search
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10
      t.string :ip_address
      t.references :user, index: true

      t.timestamps
    end
  end
end
