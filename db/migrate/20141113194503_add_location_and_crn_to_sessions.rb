class AddLocationAndCrnToSessions < ActiveRecord::Migration
  def change
  	add_column :sessions, :location, :string
  	add_column :sessions, :crn, :integer
  end
end
