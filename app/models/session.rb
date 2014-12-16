class Session < ActiveRecord::Base
  belongs_to :course
  belongs_to :instructor
end
