class CreateEmails < ActiveRecord::Migration
  def change
    create_table :emails do |t|
      t.string :name
      t.string :address
      t.references :school, index: true

      t.timestamps
    end
  end
end
