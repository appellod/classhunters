class AddOnlineToSessions < ActiveRecord::Migration
  def change
  	add_column :sessions, :online, :boolean
  end
end
