class ApisController < ActionController::Metal
	require 'open-uri'

	include ActionController::Rendering        # enables rendering
  include ActionController::MimeResponds     # enables serving different content types like :xml or :json
  include AbstractController::Callbacks      # callbacks for your authentication logic

  append_view_path "#{Rails.root}/app/views"

	#before_action :check_credentials

	def courses_select
		headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
		@results = Course.limit(50).to_json
		render 'results'
	end

	def courses_view
		headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Request-Method'] = '*'
    @results = Session.joins(:course).select('sessions.id', :crn, 'courses.name AS name', 
    	'courses.description AS description', 'courses.department AS department', 'courses.number AS number', 
    	:start_time, :end_time, :sunday, :monday, :tuesday, :wednesday, :thursday, :friday, :saturday).limit(50).to_json
    render 'results'
	end

	def courses_json
		@results = open('http://classhunters.dev/apis/courses/select').read
		@results = JSON.parse @results
		render 'test'
	end

	private

		def check_credentials
			if params[:username] != 'admin' && params[:password] != 'password'
				send_json("Incorrect username or password.")
				return false
			end
		end

		def send_json(results)
			respond_to do |format|
      	format.json  { render json: results }
      end
		end
end
