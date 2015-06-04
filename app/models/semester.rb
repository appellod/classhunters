class Semester < ActiveRecord::Base
	has_many :sessions
end
