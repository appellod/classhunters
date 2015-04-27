class CreatePluginAccesses < ActiveRecord::Migration
  def change
    create_table :plugin_accesses do |t|
      t.string :remote_ip
      t.references :school, index: true
      t.decimal :latitude, :precision => 15, :scale => 10
      t.decimal :longitude, :precision => 15, :scale => 10

      t.timestamps
    end
  end
end
