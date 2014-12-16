class Instructor < ActiveRecord::Base
	belongs_to :school
	has_many :sessions
end
