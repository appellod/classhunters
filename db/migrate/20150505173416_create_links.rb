class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :name
      t.text :url
      t.references :school, index: true

      t.timestamps
    end
  end
end
