class ApisController < ApplicationController
	#before_action :check_credentials

	def courses_select
		headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
		courses = Course.limit(50)
		send_json(courses.to_json)
	end

	def courses_view
		headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    course = Course.find(params[:id])
    send_json(course.to_json)
	end

	private

		def check_credentials
			if params[:username] != 'admin' && params[:password] != 'password'
				send_json("Incorrect username or password.")
				return false
			end
		end

		def send_json(results)
			if request.xhr?
				respond_to do |format|
					msg = { results: results }
	      	format.json  { render :json => msg }
	      end
			else
				@results = results
				render 'results', layout: nil
			end
		end
end
