module CoursesHelper
	def days(session)
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
end
