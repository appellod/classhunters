class RemoveStringFromVisits < ActiveRecord::Migration
  def change
  	remove_column :visits, "string"
  end
end
