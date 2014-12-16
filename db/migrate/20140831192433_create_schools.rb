class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.string :name
      t.string :website
      t.string :address
      t.decimal :lat
      t.decimal :lon

      t.timestamps
    end
  end
end
