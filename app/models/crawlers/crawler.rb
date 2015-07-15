class Crawler
	require 'capybara/poltergeist'
	require 'uri'
	require 'open-uri'

	def self.crawl_schools
		schools = School.where.not(crawl_url: nil).pluck(:id)
		schools.each do |school|
			Resque.enqueue(CrawlerJob, school)
		end
	end

	def initialize_session
		Capybara.register_driver :poltergeist do |app|
	    Capybara::Poltergeist::Driver.new(app, timeout: 300)
	  end
	  Capybara.default_selector = :xpath
	  Capybara.default_driver = :poltergeist
	  @session = Capybara::Session.new(:poltergeist)
	  @session.driver.headers = { 'User-Agent' =>"Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
	end

	def crawl_school(id)
		start_time = Time.now
		initialize_session
	  @school = School.find(id)
		crawl_web_advisor
		return Time.now - start_time
	end
	
	def self.find_schools
		#arr = ["Jacksonville State University", "Stillman College", "Southwestern College", "Central Baptist College", "Coleman College", "Concordia University", "Lincoln University", "Mount St. Mary's College", "Patten College", "Pomona College", "Kirkwood Community College - Cedar Rapids", "Allegany College - Cumberland", "Howard Community College - Columbia", "Prince George's Community College - Largo", "Prince George's Community College - Largo", "Bunker Hill Community College - Boston", "Dean College - Franklin", "Springfield Technical Community College - Springfield", "Alpena Community College - Alpena", "Delta College - University Center", "Henry Ford Community College - Dearborn", "Jackson Community College - Jackson", "Hinds Community College - Raymond", "Missouri College", "Southeast Community College - Beatrice", "Southeast Community College - Lincoln", "Mount Washington College", "Bergen Community College - Paramus", "County College of Morris - Randolph", "Erie Community College - Buffalo", "Mendocino College - Lakeport", "Napa Valley College - Napa", "Ohlone College - Fremont", "Palo Verde College - Blythe", "Hillsborough Community College - Brandon Campus", "Hillsborough Community College - Dale Mabry Campus", "Hillsborough Community College - Tampa", "Gainesville College", "College of DuPage - Glen Ellyn", "Joliet Junior College - Joliet", "Kankakee Community College - Kankakee", "Carroll Community College - Westminster", "Allegany College", "Monroe County Community College - Monroe", "Muskegon Community College - Muskegon", "East Central College - Union", "Southeast Community College - Milford", "Camden County College - Blackwood", "Camden County College - Camden", "Finger Lakes Community College - Newark", "Monroe College - Bronx", "Monroe College - Bronx", "Monroe Community College - Rochester", "Alamance Community College - Graham", "Brunswick Community College - Supply", "Catawba Valley Community College - Hickory", "Central Carolina Community College - Sanford", "Central Piedmont Community College - Charlotte", "Cleveland Community College - Shelby", "Coastal Carolina Community College - Jacksonville", "Craven Community College - New Bern", "Craven Community College - Havelock", "Durham Technical Community College - Durham", "Fayetteville Technical Community College - Fayetteville", "Gaston College - Dallas", "Guilford Technical Community College - Jamestown", "Isothermal Community College - Columbus", "Lenoir Community College - Kinston", "Nash Community College - Rocky Mount", "Richmond Community College - Hamlet", "Rockingham Community College - Wentworth", "Sampson Community College - Clinton", "South Piedmont Community College - Polkton", "South Piedmont Community College - Monroe", "Southeastern Community College - Whiteville", "Tri-County Community College - Murphy", "Wake Technical Community College - Raleigh", "Wilson Community College - Wilson", "Columbus State Community College - Columbus", "Hocking College - Nelsonville", "Marion Technical College - Marion", "Oklahoma City Community College - Oklahoma City", "Clackamas Community College - Oregon City", "Bucks County Community College - Newtown", "Community College of Allegheny County - Pittsburgh", "Community College of Allegheny County - Pittsburgh", "Community College of Allegheny County- Monroeville", "Community College of Philadelphia - Philadelphia", "Luzerne County Community College - Nanticoke", "Montgomery County Community College", "Montgomery County Community College", "Florence-Darlington Technical College - Florence", "Midlands Technical College - Columbia", "Trident Technical College - Charleston", "York Technical College - Rock Hill", "Alvin Community College - Alvin", "Austin Community College - Austin", "Clarendon College - Clarendon", "College of the Mainland - Texas City", "Galveston College - Galveston", "Jacksonville College - Jacksonville", "McLennan Community College - Waco", "Navarro College - Corsicana", "Odessa College - Odessa", "Richland College - Dallas", "Temple College - Temple", "Texas State Technical College: Marshall - Marshall", "Texas State Technical College: Waco - Waco", "Gateway Technical College - Elkhorn", "Gateway Technical College - Kenosha", "Gateway Technical College - Racine", "Gateway Technical College - Burlington", "Milwaukee Area Technical College - Milwaukee", "Milwaukee Area Technical College - Milwaukee", "Casper College - Casper", "Amarillo Community College - Amarillo", "Texas State Technical College: Harlingen - Harlingen"]
	  logger = Logger.new('log/crawl.log')
	  logger.info "URL Discovery Crawler initialized..."
	  schools = School.where(state: 'New Jersey').order(:name).limit(5)
	  results = Array.new
	  schools.each do |school|
	  	Resque.enqueue(CrawlerJob, school.id)
	  end
	end

	def crawl_for_urls(id)
		start_time = Time.now
		Capybara.register_driver :poltergeist do |app|
	    Capybara::Poltergeist::Driver.new(app, { js_errors: false, timeout: 30 })
	  end
	  Capybara.default_selector = :xpath
	  Capybara.default_driver = :poltergeist
	  @session = Capybara::Session.new(:poltergeist)
	  @session.driver.headers = { 'User-Agent' =>"Mozilla/5.0 (Macintosh; Intel Mac OS X)" }

		school = School.find(id)

		return school.crawl_url if school.crawl_url.present?

		str = URI.encode("#{school.name.downcase.split('-')[0].strip} course schedule")
	  @session.visit("https://www.google.com/#q=#{str}")

	  sleep 1
	  begin
	  	result = Nokogiri::HTML.parse(@session.html).css('li.g a').first.text
	  rescue
	  	sleep 5
	  	result = Nokogiri::HTML.parse(@session.html).css('li.g a').first.text
	  end
	  @session.first(:link, result).click
	  
	  if @session.html.match(/displayFormHTML/i)
	  	url ||= @session.current_url
	  	crawl_type = 'portal'
	  elsif @session.html.match(/headerwrapperdiv/i)
	  	url ||= @session.current_url
	  	crawl_type = 'wa'
	  end

	  nokogiri_links = Nokogiri::HTML.parse(@session.html).css('a')

	  nokogiri_links.each do |link|
	  	break if url.present? || (Time.now - start_time) > 300
	  	begin
	  		uri = URI.parse(link['href'])
		  	if uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
			  	if link['href'].match(/bwckschd/i)
		  			url ||= link['href']
		  			crawl_type ||= 'portal'
		  		elsif link['href'].match(/webadvisor/i)
		  			url ||= link['href']
		  			crawl_type = 'wa'
		  		end
		  	end
	  	rescue
	  	end
	  end

	  nokogiri_links.each do |link|
	  	break if url.present? || (Time.now - start_time) > 300
	  	begin
		  	uri = URI.parse(link['href'])
		  	if uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::HTTPS)
			  	@session.visit(link['href'])
			  	html = @session.html
			  	if html.match(/headerwrapperdiv/i) || @session.current_url.match(/bwckschd/i)
			  		url ||= @session.current_url
			  		crawl_type = 'portal'
			  	elsif html.match(/displayFormHTML/i) || @session.current_url.match(/webadvisor/i)
			  		url ||= @session.current_url
			  		crawl_type = 'wa'
			  	end
		  	end
	  	rescue
			end
	  end

	  if url.present?
	  	school.update_attributes(crawl_url: url, crawl_type: crawl_type)
	  end

	  return url.present? ? url : "No URL found"
	end
  
end