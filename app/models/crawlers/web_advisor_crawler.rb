class WebAdvisorCrawler < Crawler

	def self.queue_schools
	  logger = Logger.new('log/crawl.log')
	  logger.info "WebAdvisor Crawler: Queueing Schools"
	  if Rails.env == 'development'
	  	schools = School.where(crawl_type: 'wa')
	  else
	  	schools = School.where(crawl_type: 'wa')
	  end
	  schools.each do |school|
	  	Resque.enqueue(WebAdvisorCrawlerJob, school.id)
	  end
	end

	def crawl(id)
		initialize_session
		@school = School.find(id)
  	url = @school.crawl_url
  	if url.include?('?')
  		url = url.split('?')[0]
  	end
	  @session.visit(url)
	  click_students_link
	  click_search_link
	  fill_search_form
	  begin
	  	table = generate_table(Nokogiri::HTML.parse(@session.html).css('table[summary=Sections]'))
	  rescue
	  	sleep 10
			table = generate_table(Nokogiri::HTML.parse(@session.html).css('table[summary=Sections]'))
		end
	  table = parse_table(table)
	  pages = Nokogiri::HTML.parse(@session.html).css('.envisionWindow table tbody tr td:nth-child(2)').to_s.match(/Page [0-9]+ of [0-9]+/).to_s
	  current_page = pages.scan(/[0-9]+/)[0].to_i
	  total_pages = pages.scan(/[0-9]+/)[1].to_i
	  while current_page < total_pages
	  	@session.first(:button, 'NEXT').click
	  	table = generate_table(Nokogiri::HTML.parse(@session.html).css('table[summary=Sections]'))
	  	table = parse_table(table)
	  	pages = Nokogiri::HTML.parse(@session.html).css('.envisionWindow table tbody tr td:nth-child(2)').to_s.match(/Page [0-9]+ of [0-9]+/).to_s
	  	current_page = pages.scan(/[0-9]+/)[0].to_i
	  	total_pages = pages.scan(/[0-9]+/)[1].to_i
	  end
	end

	def click_students_link
		begin
			html = Nokogiri::HTML.parse(@session.html).css('a')
			link_text = nil
			html.each do |link|
				if link.to_s.include?('WBST')
					link_text = link.text
				end
			end
			@session.first(:link, link_text.strip).click
		rescue
			begin
				html = Nokogiri::HTML.parse(@session.html).css('a')
				link_text = nil
				html.each do |link|
					if link.to_s.include?('WBAP')
						link_text = link.text
					end
				end
				@session.first(:link, link_text.strip).click
			rescue
				begin
					html = Nokogiri::HTML.parse(@session.html).css('a')
					link_text = nil
					html.each do |link|
						if link.to_s.include?('WBGU')
							link_text = link.text
						end
					end
					@session.find_link(link_text.strip).click
				rescue
					begin
						html = Nokogiri::HTML.parse(@session.html).css('a')
						link_text = nil
						html.each do |link|
							if link.to_s.include?('WBCE')
								link_text = link.text
							end
						end
						@session.find_link(link_text.strip).click
					rescue
					end
				end
			end
		end
	end

	def click_search_link
		begin
			html = Nokogiri::HTML.parse(@session.html).css('a')
			link_text = nil
			html.each do |link|
				if link.to_s.include?('WESTS')
					link_text ||= link.text
				end
			end
			@session.first(:link, link_text.strip).click
		rescue
		end
=begin
		begin
			@session.first(:link, 'Search for Sections').click
		rescue
			begin
			@session.find_link('Search for Classes (No Login Required)').click
			rescue
				begin
					@session.find_link('Search for Sections').click
				rescue
				end
			end
		end
=end
	end

	def fill_search_form
		#@session.find_field('Starting On/After Date').set(Time.now.strftime('%m/%d/%Y'))
		#@session.find_field('Ending By Date').set('12/31/' + Time.now.year.to_s)
		begin
			@session.find(:css, '#DATE_VAR1').set(Time.now.strftime('%m/%d/%Y'))
			@session.find(:css, '#DATE_VAR2').set('12/31/' + Time.now.year.to_s)
		rescue
			@session.all(:css, '#VAR1 option')[1].select_option
		end
		@session.find_field('Mon').set(true)
		@session.find_field('Tue').set(true)
		@session.find_field('Wed').set(true)
		@session.find_field('Thu').set(true)
		@session.find_field('Fri').set(true)
		@session.find_field('Sat').set(true)
		@session.find_field('Sun').set(true)
		academic_level_field = @session.find_field('Academic Level')
		begin
			academic_level_field.select('Undergraduate')
		rescue
			#@session.all(:css, '#' + academic_level_field[:id] + ' option')[1].select_option
		end
		@session.click_button('SUBMIT')
		#Handle End Date Errors
		error = Nokogiri::HTML.parse(@session.html).css('#bodyForm .custom .errorText').to_s
		if error.present?
			dates = error.scan(/[0-9]+.[0-9]+.[0-9]+/)
			@session.find_field('Ending By Date').set(dates[1])
			@session.click_button('SUBMIT')
		end
		error = Nokogiri::HTML.parse(@session.html).css('#bodyForm .custom .errorText').to_s
		if error.present?
			day_count = error.scan(/[0-9]+.days/).first.to_i
			@session.find_field('Ending By Date').set((Time.now + day_count.days).strftime('%m/%d/%Y'))
		end
	end

	def generate_table(table)
		rowCells = Array.new
		headers = get_table_headers(table)
		table.search('tr').each do |tr|
		  cells = Hash.new
		  tr.search('td').each_with_index do |cell, i|
		    cells[headers[i]] = cell.text.gsub(/\r\n?/, "").strip
		  end
		  rowCells.push(cells) if cells.present?
		end
		return rowCells
	end

	def get_table_headers(table)
		tr = table.search('tr')[1]
	  cells = Array.new
	  tr.search('th').each do |cell|
	    cells.push(cell.text.strip.parameterize.gsub('-', '_'))
	  end
		return cells
	end

	def parse_table(table)
			table.each do |row|
				begin
					parse_terms(row)
					parse_status(row)
					parse_section_name_and_title(row)
					parse_location(row)
					parse_meeting_information(row)
					parse_faculty(row)
					parse_available_capacity_waitlist(row)
					parse_credits(row)
					parse_ceus(row)
					parse_academic_level(row)
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

	def parse_terms(row)
		if row['term'].present?
			term = row['term'].downcase
			seasons = ['spring', 'summer', 'fall', 'winter']
			season = term.split(/[^[:alpha:]]+/) & seasons
			years = (2000..2050).to_a.map(&:to_s)
			year = term.split(/[^[:alnum:]]+/) & years
			if season.count > 0 && year.count > 0
				row['semester_season'] = season.count > 0 ? season[0].downcase : ""
				row['semester_year'] = year[0]
			end
		end
		return row
	end

	def parse_status(row)
		row['section_status'] = row['status'].downcase if row['status'].present?
		return row
	end

	def parse_section_name_and_title(row)
		if row['section_name_and_title'].present?
			title = row['section_name_and_title']
			department = title.split(/[^[:alnum:]]+/)[0]
			number = title.split(/[^[:alnum:]]+/)[1]
			crn = title.split(/[^[:alnum:]]+/)[3]
			if title.include?(')')
				name = title.split(')')[1]
			else
				name = title.rpartition(/[0-9]{2,}/)[2]
			end
			name = name.strip if name.present?
			row['course_department'] = department
			row['course_number'] = number
			row['section_crn'] = crn
			row['course_name'] = name
		end
		return row
	end

	def parse_location(row)
		if row['location'].present?
			location = row['location']
			row['section_location'] = location
			if location.include?('Distance Education')
				row['section_online'] = 1
			else
				row['section_online'] = 0
			end
		end
		return row
	end

	def parse_meeting_information(row)
		if row['meeting_information'].present?
			str = row['meeting_information'].downcase
			dates = str.scan(/[0-9]+.[0-9]+.[0-9]+/)
			dates.each do |date|
				date.gsub!(/[^0-9]/i, '/')
			end
			start_date = Date.strptime(dates[0], '%m/%d/%Y').to_s
			end_date = Date.strptime(dates[1], '%m/%d/%Y').to_s
			day_names = Date::DAYNAMES
			days = str.split(/[^[:alpha:]]+/) & day_names.map{|c| c.downcase}
			day_names.map{|c| c.downcase}.each do |day|
				if days.include?(day)
					row['section_'+day] = 1
				else
					row['section_'+day] = 0
				end
			end
			times = str.scan(/[0-9]+:[0-9]+[am|pm]+/)
			row['section_start_time'] = times[0]
			row['section_end_time'] = times[1]
			row['section_start_date'] = start_date
			row['section_end_date'] = end_date
		end
		return row
	end

	def parse_faculty(row)
		if row['faculty'].present?
			row['section_faculty'] = row['faculty']
		end
		return row
	end

	def parse_available_capacity_waitlist(row)
		if row['available_capacity_waitlist'].present?
			str = row['available_capacity_waitlist']
			row['section_available'] = str.split('/')[0].strip
			row['section_capacity'] = str.split('/')[1].strip
			row['section_waitlist'] = str.split('/')[2].strip
		end
		return row
	end

	def parse_credits(row)
		if row['credits'].present?
			row['section_credits'] = row['credits']
		end
		return row
	end

	def parse_ceus(row)
		if row['ceus'].present?
			row['section_ceus'] = row['ceus']
		end
		return row
	end

	def parse_academic_level(row)
		if row['academic_level'].present?
			row['section_academic_level'] = row['academic_level'].downcase
		end
		return row
	end

	def get_description(row)
		name_and_title = @session.find_link(row['section_name_and_title'])
		name_and_title.click unless name_and_title.nil?
		@session.within_window(@session.driver.window_handles.last) do
			begin
			  page = Nokogiri::HTML.parse(@session.html).css('table[summary="This panel contains controls that are vertically  aligned."]')
			  page = page.search('p#VAR3')[0].text
				row['course_description'] = page
			rescue
				row['course_description'] = ""
			end
			begin
				@session.find(:css, '.submit .expandingButton').click
			rescue
				sleep 5
				begin
					@session.find(:css, '.submit .expandingButton').click
				rescue
					@session.execute_script('forceCloseWindow();')
				end
			end
		end
	end

	def save_row(row)
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
	end
end