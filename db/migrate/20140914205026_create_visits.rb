class CreateVisits < ActiveRecord::Migration
  def change
    create_table :visits do |t|
      t.string :remote_ip
      t.string :referrer
      t.string :string

      t.timestamps
    end
  end
end
