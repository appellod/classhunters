class Course < ActiveRecord::Base
	require 'csv'

	belongs_to :school
	has_and_belongs_to_many :users
	has_many :sessions, dependent: :destroy
	has_many :sections, dependent: :destroy
	has_and_belongs_to_many :course_searches

	before_validation :strip_attributes

	validates :name, presence: true

	searchable do
		text :name, boost: 2.0
		text :description, :department
		string :school_id_str, stored: true do
      school_id.to_s
    end
		latlon(:location) { Sunspot::Util::Coordinates.new(school.latitude, school.longitude) }
	end

	def strip_attributes
		self.name = self.name.strip
		self.description = self.description.strip unless self.description.nil?
		self.department = self.department.strip unless self.department.nil?
	end

	def self.import(file, school_id, semester)
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
	    if row['number'].present?
	    	course = school.courses.where(department: row['department'], number: row['number'])
			else
				course = school.courses.where(department: row['department'])
			end
	    if course.count == 1
	    	course = course.first
	    else
	      course = school.courses.build
	      course = setName(course, row)
	      course = setDepartment(course, row)
	      course.save
	    end
	    session = course.sessions.build
	    session = setDays(session, row)
	    session = setLocation(session, row)
	    session = setRoom(session, row)
	    session = setCRN(session, row)
	    session = setCredits(session, row)
	    session = setOnline(session, row)
	    session.semester = semester
	    if row["instructor"].present?
		    instructor = school.instructors.where(name: row["instructor"].strip)
		    if instructor.count == 1
		    	instructor = instructor.first
		    else
		    	instructor = school.instructors.create!(name: row["instructor"].strip)
		    end
		    session.instructor = instructor
		  end
	    session = setTime(session, row)
	    session.save
	  end
	end

	def self.import_descriptions(file, school_id)
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
	    if row['number'].present?
	    	course = school.courses.where(department: row['department'], number: row['number'])
			else
				course = school.courses.where(department: row['department'])
			end
	    if course.count == 1
	    	course = course.first
	      course = setName(course, row)
	      course = setDepartment(course, row)
	      course = setDescription(course, row)
	    else
	      course = school.courses.build
	      course = setName(course, row)
	      course = setDepartment(course, row)
	      course = setDescription(course, row)
	    end
	    course.save
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

	def self.setName(course, row)
		if row['name'].present?
			name = ''
			if row['name'] == row['name'].upcase
				exceptions = ["and", "the", "to", "of", "by", "from", "or", 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X']
				name_split = row['name'].split(' ')
				name_split.each_with_index do |word, i|
					if !exceptions.include?(word)
						if word.titleize.split(' ').count == 1
							name_split[i] = word.titleize
						end
					end
				end
				name = name_split.join(' ')
			else
				name = row['name']
			end
			if course.name.present?
				if row['name'].downcase.include?('online') && course.name.downcase.include?('online')
					course.name = name
				elsif !row['name'].downcase.include?('online') && !course.name.downcase.include?('online')
					course.name = name
				end
			else
				course.name = name
			end
		end
		return course
	end

	def self.setDepartment(course, row)
		if row['department'].present?
			if row['number'].present?
				course.department = row['department']
				course.number = row['number']
			else
				course.department = row['department']
			end
		end
		return course
	end

	def self.setDescription(course, row)
		if row['description'].present?
			description = row['description'].gsub('\\n', '<br>')
			course.description = description
		end
		return course
	end

	def self.setDays(session, row)
		if row['days'].present?
			days = row['days'].downcase
			if days.include? 'm'
				session.monday = true
			end
			if days.include? 't'
				session.tuesday = true
			end
			if days.include? 'w'
				session.wednesday = true
			end
			if days.include?('r') || days.include?('h')
				session.thursday = true
			end
			if days.include? 'f'
				session.friday = true
			end
			if days.include? 's'
				session.saturday = true
			end
		end
		return session
	end

	def self.setLocation(session, row)
		if row['location'].present?
			session.location = row['location']
		end
		return session
	end

	def self.setRoom(session, row)
		if row['room'].present?
			session.room = row['room']
		end
		return session
	end

	def self.setCRN(session, row)
		if row['crn'].present?
			session.crn = row['crn']
		end
		return session
	end

	def self.setCredits(session, row)
		if row['credits'].present?
			session.credits = row['credits']
		end
		return session
	end

	def self.setTime(session, row)
		if row['time'].present?
			begin
				time = row['time']
				time = time.downcase
				if time.length == 11
					time.insert 2, ':'
					time.insert 8, ':'
					start_time = time[0..4]
					end_time = time[6..12]
					start_time = Time.parse(start_time)
					end_time = Time.parse(end_time)
					if end_time >= Time.parse('13:00') && start_time + 12*60*60 < end_time
						start_time = start_time + 12*60*60
					end
				elsif time.length == 15
					start_time = Time.parse(time[0..6])
					end_time = Time.parse(time[8..15])
				elsif time.length == 13 || time.length == 14
					start_time = Time.parse(time.split('-')[0])
					end_time = Time.parse(time.split('-')[1])
				end
				session.start_time = start_time.to_s[10..18]
				session.end_time = end_time.to_s[10..18]
			rescue ArgumentError
				return session
			end
		end
		return session
	end

	def self.setOnline(session, row)
		row.each do |key, value|
			if value.present? && value.to_s.downcase.include?('online')
				session.online = true
			end
		end
		return session
	end
end
