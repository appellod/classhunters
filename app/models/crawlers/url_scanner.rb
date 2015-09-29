class URLScanner
	require 'capybara/poltergeist'
	require 'uri'
	require 'open-uri'

	def initialize_session
		Capybara.register_driver :poltergeist do |app|
	    Capybara::Poltergeist::Driver.new(app, { js_errors: false, timeout: 30 })
	  end
	  Capybara.default_selector = :xpath
	  Capybara.default_driver = :poltergeist
	  @session = Capybara::Session.new(:poltergeist)
	  @session.driver.headers = { 'User-Agent' =>"Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
	end
	
	def self.queue_schools
	  logger = Logger.new('log/crawl.log')
	  logger.info "URL Scanner: Queueing Schools"
	  if Rails.env == 'development'
	  	schools = School.where(state: 'New Jersey').order(:name).limit(5)
	  else
	  	schools = School.where.not(crawl_url: nil).order(:name)
	  end
	  schools.each do |school|
	  	Resque.enqueue(URLScannerJob, school.id)
	  end
	end

	def scan_school(id)
		start_time = Time.now
		initialize_session

		school = School.find(id)

	  google(school)
	  
	  school = check_for_match(school)

	  nokogiri_links = Nokogiri::HTML.parse(@session.html).css('a')

	  school = scan_links(start_time, nokogiri_links, school)
	  school = visit_links(start_time, nokogiri_links, school)

	  school.save if school.changed.present?

	  return school.crawl_url.present? ? school.crawl_url : "No URL found"
	end

	def google(school)
		query = URI.encode("#{school.name.downcase.split('-')[0].strip} course schedule")
		@session.visit("https://www.google.com/#q=#{query}")
	  sleep 1
	  begin
	  	result = Nokogiri::HTML.parse(@session.html).css('li.g a').first.text
	  rescue
	  	sleep 5
	  	result = Nokogiri::HTML.parse(@session.html).css('li.g a').first.text
	  end
	  @session.first(:link, result).click
	end

	def scan_links(start_time, links, school)
		links.each do |link|
	  	break if school.crawl_url.present? || (Time.now - start_time) > 300
	  	begin
	  		uri = URI.parse(link['href'])
		  	if uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
			  	if link['href'].match(/bwckschd/i)
		  			school.crawl_url ||= link['href']
		  			school.crawl_type ||= 'portal'
		  		elsif link['href'].match(/webadvisor/i)
		  			school.crawl_url ||= link['href']
		  			school.crawl_type ||= 'wa'
		  		end
		  	end
	  	rescue
	  	end
	  end
	  return school
	end

	def visit_links(start_time, links, school)
		links.each do |link|
	  	break if school.crawl_url.present? || (Time.now - start_time) > 300
	  	begin
		  	uri = URI.parse(link['href'])
		  	if uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
			  	@session.visit(link['href'])
			  	html = @session.html
			  	check_for_match(school)
		  	end
	  	rescue
			end
	  end
	  return school
	end

	def check_for_match(school)
  	if @session.html.match(/headerwrapperdiv/i) || @session.current_url.match(/bwckschd/i)
  		school.crawl_url ||= @session.current_url
  		school.crawl_type ||= 'portal'
  	elsif @session.html.match(/displayFormHTML/i) || @session.current_url.match(/webadvisor/i)
  		school.crawl_url ||= @session.current_url
  		school.crawl_type ||= 'wa'
  	end
  	return school
  end

end