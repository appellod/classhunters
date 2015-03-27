class Session < ActiveRecord::Base
  belongs_to :course
  belongs_to :instructor
  has_and_belongs_to_many :session_searches

  before_validation :strip_attributes

  def strip_attributes
		self.location = self.location.strip unless self.location.nil?
		self.semester = self.semester.strip unless self.semester.nil?
	end
end
