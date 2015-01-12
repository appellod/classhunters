class Instructor < ActiveRecord::Base
	belongs_to :school
	has_many :sessions

	before_validation :strip_attributes

	def strip_attributes
		self.name = self.name.strip
	end
end
