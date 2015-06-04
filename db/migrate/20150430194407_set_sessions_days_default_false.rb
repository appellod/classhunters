class SetSessionsDaysDefaultFalse < ActiveRecord::Migration
  def change
  	Session.all.each do |session|
  		session.sunday = 0 if session.sunday.nil?
  		session.monday = 0 if session.monday.nil?
  		session.tuesday = 0 if session.tuesday.nil?
  		session.wednesday = 0 if session.wednesday.nil?
  		session.thursday = 0 if session.thursday.nil?
  		session.friday = 0 if session.friday.nil?
  		session.saturday = 0 if session.saturday.nil?
  		session.save
  	end
  	change_column :sessions, :sunday, :boolean, null: false, default: false
  	change_column :sessions, :monday, :boolean, null: false, default: false
  	change_column :sessions, :tuesday, :boolean, null: false, default: false
  	change_column :sessions, :wednesday, :boolean, null: false, default: false
  	change_column :sessions, :thursday, :boolean, null: false, default: false
  	change_column :sessions, :friday, :boolean, null: false, default: false
  	change_column :sessions, :saturday, :boolean, null: false, default: false
  end
end
