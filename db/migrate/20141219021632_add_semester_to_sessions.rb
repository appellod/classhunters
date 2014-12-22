class AddSemesterToSessions < ActiveRecord::Migration
  def change
  	add_column :sessions, :semester, :string
  end
end
