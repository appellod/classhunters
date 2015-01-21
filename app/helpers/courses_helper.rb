module CoursesHelper
	def days_to_string(session)
		str = ''
		if session.sunday?
			str += 'Su'
		end
		if session.monday?
			str += 'M'
		end
		if session.tuesday?
			str += 'T'
		end
		if session.wednesday?
			str += 'W'
		end
		if session.thursday?
			str += 'R'
		end
		if session.friday?
			str += 'F'
		end
		if session.saturday?
			str += 'S'
		end
		return str
	end

	def semesters_select
		[
			['All Semesters', ''], 'Summer 2015', 'Spring 2015', 'Winter 2014', 'Fall 2014'
		]
	end

	def semesters
		[
			'Spring 2015', 'Summer 2015', 'Fall 2015', 'Winter 2015'
		]
	end

	def times
		time = Time.parse('2015/1/1')
		times = Array.new
		for i in 0..23
			times << time.strftime('%l:%M%p')
			time += 1.hour
		end
		return times
	end
end
