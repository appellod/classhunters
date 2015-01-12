class AddCreditsToSessions < ActiveRecord::Migration
  def change
  	add_column :sessions, :credits, :decimal, :precision => 4, :scale => 2
  end
end
