class Section < ActiveRecord::Base
  belongs_to :semester
  belongs_to :course
end
