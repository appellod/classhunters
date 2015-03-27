class CreateJoinTableCourseCourseSearch < ActiveRecord::Migration
  def change
    create_join_table :courses, :course_searches do |t|
      # t.index [:course_id, :course_search_id]
      # t.index [:course_search_id, :course_id]
    end
  end
end
