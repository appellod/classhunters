class Course < ActiveRecord::Base
	require 'csv'

	belongs_to :school
	has_and_belongs_to_many :users
	has_many :sessions

	validates :name, presence: true

	searchable do
		text :name, :description, :department
		string(:school_id_str) { |p| p.school_id.to_s }
	end

	def self.import(file, school_id)
		school = School.find(school_id)
	  spreadsheet = open_spreadsheet(file)
	  header = spreadsheet.row(1)
	  (2..spreadsheet.last_row).each do |i|
	    row = Hash[[header, spreadsheet.row(i)].transpose]
	    row.each do |item|
	    	if item[1].is_a? String
	    		item[1].strip!
	    	end
	    end
	    course = school.courses.where(name: row["name"])
	    if course.count == 1
	    	course = course.first
	      course = setCourseAttributes(course, row)
	    else
	      course = school.courses.build
	      course = setCourseAttributes(course, row)
	    end
	    course.save
	    session = course.sessions.build
	    session = self.parseDay(row['days'], session)
	    session.location = row["location"]
	    session.room = row["room"]
	    session.crn = row['crn']
	    session.credits = row['credits']
	    instructor = school.instructors.where(name: row["instructor"])
	    if instructor.count == 1
	    	instructor = instructor.first
	    else
	    	instructor = school.instructors.create!(name: row["instructor"])
	    end
	    session.instructor = instructor
	    session = self.parseTime(row['time'], session)
	    session.save
	    sleep 0.2
	  end
	end

	def self.open_spreadsheet(file)
	  case File.extname(file.original_filename)
	  when ".csv" then Roo::CSV.new(file.path, file_warning: :ignore)
	  when ".xls" then Roo::Excel.new(file.path, file_warning: :ignore)
	  when ".xlsx" then Roo::Excelx.new(file.path, file_warning: :ignore)
	  else raise "Unknown file type: #{file.original_filename}"
	  end
	end

	def self.setCourseAttributes(course, row)
		if row['name'].present?
			course.name = row['name']
			if row['department'].present?
				if row['department'].include? ' '
					course.department = row['department'].split(' ')[0]
					course.department = row['department'].split(' ')[1]
				else
					course.department = row['department']
				end
			end
		end
		return course
	end

	def self.parseDay(str, session)
		if str.present?
			str = str.downcase
			if str.include? 'm'
				session.monday = true
			end
			if str.include? 't'
				session.tuesday = true
			end
			if str.include? 'w'
				session.wednesday = true
			end
			if str.include? 'r'
				session.thursday = true
			end
			if str.include? 'f'
				session.friday = true
			end
			if str.include? 's'
				session.saturday = true
			end
		end
		return session
	end

	def self.parseTime(str, session)
		if str.present?
			if !str.include? 'TBA'
				str = str.downcase
				str.insert 2, ':'
				str.insert 8, ':'
				start_time = str[0..4]
				end_time = str[6..12]
				start_time = Time.parse(start_time)
				end_time = Time.parse(end_time)
				if end_time >= Time.parse('13:00') && start_time + 12*60*60 < end_time
					start_time = start_time + 12*60*60
				end
				session.start_time = start_time.to_s[10..18]
				session.end_time = end_time.to_s[10..18]
			end
		end
		return session
	end
end
