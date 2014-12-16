class AddRoomToSessions < ActiveRecord::Migration
  def change
  	add_column :sessions, :room, :string
  end
end
