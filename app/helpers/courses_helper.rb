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
			'Summer 2015', 'Spring 2015', 'Winter 2014', 'Fall 2014'
		]
	end
end
