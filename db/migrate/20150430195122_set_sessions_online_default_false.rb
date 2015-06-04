class SetSessionsOnlineDefaultFalse < ActiveRecord::Migration
  def change
  	Session.all.each do |session|
  		session.online = 0 if session.online.nil?
  		session.save
  	end
  	change_column :sessions, :online, :boolean, null: false, default: false
  end
end
