class AddRefererToPluginAccesses < ActiveRecord::Migration
  def change
  	add_column :plugin_accesses, :referer, :text
  end
end
