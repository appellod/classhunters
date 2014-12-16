class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :input
      t.string :remote_ip
      t.string :page

      t.timestamps
    end
  end
end
