class PortalCrawler < Crawler
	require 'uri'

	def crawl
		initialize_session
		@session.visit("https://selfservice.drew.edu/prod/bwckschd.p_disp_dyn_sched")
		@school = School.find(849)
		@logger = Logger.new('log/crawl.log')
		select_term_or_dates
		select_all_subjects
		begin
	  	table = generate_table(Nokogiri::HTML.parse(@session.html).css('.pagebodydiv > table.datadisplaytable'))
	  rescue
	  	sleep 10
			table = generate_table(Nokogiri::HTML.parse(@session.html).css('.pagebodydiv > table.datadisplaytable'))
		end
		table = parse_table(table)
	end

	def select_term_or_dates
		@session.first(:css, "#from_id").set(Time.now.strftime('%m/%d/%Y'))
		@session.first(:css, "#to_id").set('12/31/' + Time.now.year.to_s)
		@session.first(:button, "Submit").click
	end

	def select_all_subjects
		subjects = @session.all(:css, "#subj_id option")
		subjects.each do |option|
			@session.select option.text, from: 'Subject:'
		end
		@session.first(:button, "Class Search").click
	end

	def generate_table(table)
		row_cells = Array.new
		cells = Hash.new
		title_found = false
		table.search('tr').each do |tr|
			text = tr.text
			if text =~ /.+\- [0-9]+ \- [A-Z]+ [0-9]+.*/
				if title_found
					row_cells.push(cells)
					cells = Hash.new
				end
				cells['title'] = text.gsub!(/\n/, '')
				title_found = true
			elsif title_found
				cells['info'] = tr.to_s
				row_cells.push(cells)
				cells = Hash.new
				title_found = false
			end
		end
		return row_cells
	end

	def parse_table(table)
		table.each do |row|
			begin
				parse_title(row)
				parse_semester(row)
				parse_academic_level(row)
				parse_credits(row)
				parse_meeting_info(row)
				get_seats(row)
				get_description(row)
				save_row(row)
			rescue Exception => e
				if Rails.env == 'development'
					raise e
				end
			end
		end
		return table
	end

	def parse_title(row)
		start_time = Time.now
		if row['title'].present?
			title = row['title']
			row['course_name'] = title.split(/ - [0-9]+ - /)[0]
			row['section_crn'] = title.scan(/ - [0-9]+ - /)[0].gsub!(/ - /, '')
			department_number = title.split(/ - [0-9]+ - /)[1]
			row['course_department'] = department_number.scan(/[A-Z]+/)[0]
			row['course_number'] = department_number.scan(/[0-9]+/)[0]
		end
		@logger.info "parse_title: " + (Time.now - start_time).to_s
		return row
	end

	def parse_semester(row)
		start_time = Time.now
		if row['info'].present?
			info = row['info']
			semester_year = info.scan(/(?:Spring|Summer|Fall|Winter) [0-9]+/i)[0]
			row['semester_season'] = semester_year.split(' ')[0] if semester_year.present?
			row['semester_year'] = semester_year.split(' ')[1] if semester_year.present?
		end
		@logger.info "parse_semester: " + (Time.now - start_time).to_s
		return row
	end

	def parse_academic_level(row)
		start_time = Time.now
		if row['info'].present?
			info = row['info']
			if info =~ /undergraduate/i
				row['section_academic_level'] = "undergraduate"
			end
		end
		@logger.info "parse_academic_level: " + (Time.now - start_time).to_s
		return row
	end

	def parse_credits(row)
		start_time = Time.now
		if row['info'].present?
			info = row['info']
			credits = info.scan(/[0-9]+.[0-9]+ Credits/i)[0]
			row['section_credits'] = credits.split(' ')[0].to_f
		end
		@logger.info "parse_credits: " + (Time.now - start_time).to_s
		return row
	end

	def get_seats(row)
		start_time = Time.now
		begin
			domain = URI.parse('https://selfservice.drew.edu/prod/bwckschd.p_disp_dyn_sched')
			href = @session.find_link(row['title'])['href']
			seats_url = domain.scheme + '://' + domain.host + href
			@session.execute_script("window.open('#{seats_url}', 'window_name', 'height=800,width=1000');")
			@session.within_window(@session.driver.window_handles.last) do
			  page = Nokogiri::HTML.parse(@session.html).css('table[summary="This layout table is used to present the seating numbers."] tr:nth-child(2)')
			  row['section_available'] = page.css('td:nth-child(4)').text
			  row['section_capacity'] = page.css('td:nth-child(2)').text
			  @session.execute_script("window.close();")
			end
		rescue
		end
		@logger.info "get_seats: " + (Time.now - start_time).to_s
		return row
	end

	def get_description(row)
		start_time = Time.now
		begin
			domain = URI.parse('https://selfservice.drew.edu/prod/bwckschd.p_disp_dyn_sched')
			href = Nokogiri::HTML.parse(row['info'].scan(/<a href="(.*[^"])">View Catalog Entry<\/a>/i)[0][0]).text
			description_url = domain.scheme + '://' + domain.host + href
			@session.execute_script("window.open('#{description_url}', 'window_name', 'height=800,width=1000');")
			@session.within_window(@session.driver.window_handles.last) do
				description = Nokogiri::HTML.parse(@session.html).css('td.ntdefault').first.children.first.to_s.gsub!(/\n/, '')
				row['course_description'] = description
				@session.execute_script("window.close();")
			end
		rescue
		end
		@logger.info "get_description: " + (Time.now - start_time).to_s
		return row
	end

	def parse_meeting_info(row)
		if row['info'].present?
			info = Nokogiri::HTML.parse(row['info'])
			table = info.css('table.datadisplaytable tr:nth-child(2)')
			start_time = table.css('td:nth-child(2)').to_s.scan(/[0-9]+:[0-9]+ [A-Za-z]{2}/)[0]
			start_time = start_time.gsub!(/ /, '') if start_time.present?
			end_time = table.css('td:nth-child(2)').to_s.scan(/[0-9]+:[0-9]+ [A-Za-z]{2}/)[1]
			end_time = end_time.gsub!(/ /, '') if end_time.present?
			row['section_start_time'] = start_time
			row['section_end_time'] = end_time
			days = table.css('td:nth-child(3)').to_s
			row['section_sunday'] = days.include?('Su') ? 1 : 0
			row['section_monday'] = days.include?('M') ? 1 : 0
			row['section_tuesday'] = days.include?('T') ? 1 : 0
			row['section_wednesday'] = days.include?('W') ? 1 : 0
			row['section_thursday'] = days.include?('R') ? 1 : 0
			row['section_friday'] = days.include?('F') ? 1 : 0
			row['section_saturday'] = days.include?('S') ? 1 : 0
			row['section_location'] = table.css('td:nth-child(4)').text
			start_date = table.to_s.scan(/[A-Za-z]+ [0-9]+, [0-9]+/)[0]
			start_date = Date.parse(start_date).to_s if start_date.present?
			end_date = table.to_s.scan(/[A-Za-z]+ [0-9]+, [0-9]+/)[1]
			end_date = Date.parse(end_date).to_s if end_date.present?
			row['section_start_date'] = start_date
			row['section_end_date'] = end_date
			row['section_online'] = table =~ /online/i ? 1 : 0
			faculty = table.css('td:nth-child(7)').text
			faculty = faculty.gsub!(/ *\(.*\) */, '') if faculty.present?
			row['section_faculty'] = faculty.gsub!(/\n/, '') if faculty.present?
			faculty_email = table.css('td:nth-child(7) a')
			faculty_email = faculty_email[0]['href'].to_s if faculty_email.present?
			row['section_faculty_email'] = faculty_email.gsub!('mailto:', '') if faculty_email.present?
		end
		return row
	end

	def save_row(row)
		start_time = Time.now
		temp_course = @school.courses.where(department: row['course_department'], number: row['course_number'])
		if temp_course.count > 0
			course = temp_course.first
			course.name = row['course_name'] if row['course_name'].present?
			course.description = row['course_description'] if row['course_description'].present?
		else
			course = @school.courses.create!(name: row['course_name'], description: row['course_description'],
				department: row['course_department'], number: row['course_number']) if row['course_name'].present?
		end
		if row['semester_season'].present?
			temp_semester = Semester.where(name: row['semester_season'], year: row['semester_year'])
			if temp_semester.count > 0
				semester = temp_semester.first
			else
				semester = Semester.create!(name: row['semester_season'], year: row['semester_year'])
			end
			temp_section = course.sections.where(crn: row['section_crn'])
			if temp_section.count > 0
				section = temp_section.first
			else
				section = course.sections.build
			end
			section.status = row['section_status']
			section.crn = row['section_crn']
			section.location = row['section_location']
			section.online = row['section_online']
			section.sunday = row['section_sunday']
			section.monday = row['section_monday']
			section.tuesday = row['section_tuesday']
			section.wednesday = row['section_wednesday']
			section.thursday = row['section_thursday']
			section.friday = row['section_friday']
			section.saturday = row['section_saturday']
			section.start_time = row['section_start_time']
			section.end_time = row['section_end_time']
			section.start_date = row['section_start_date']
			section.end_date = row['section_end_date']
			section.faculty = row['section_faculty']
			section.available = row['section_available']
			section.capacity = row['section_capacity']
			section.waitlist = row['section_waitlist']
			section.credits = row['section_credits']
			section.academic_level = row['section_academic_level']
			section.semester = semester
			section.save
		end
		@logger.info "save_row: " + (Time.now - start_time).to_s
	end

end