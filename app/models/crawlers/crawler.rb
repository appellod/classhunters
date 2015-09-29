class Crawler
	require 'capybara/poltergeist'
	require 'uri'
	require 'open-uri'

	def self.queue_schools
		schools = School.where.not(crawl_url: nil).pluck(:id)
		schools.each do |school|
			Resque.enqueue(CrawlerJob, school)
		end
	end

	def initialize_session
		Capybara.register_driver :poltergeist do |app|
	    Capybara::Poltergeist::Driver.new(app, { timeout: 300, phantomjs_options: ['--load-images=no', '--disk-cache=false', '--ignore-ssl-errors=yes'] })
	  end
	  Capybara.default_selector = :xpath
	  Capybara.default_driver = :poltergeist
	  @session = Capybara::Session.new(:poltergeist)
	  @session.driver.headers = { 'User-Agent' =>"Mozilla/5.0 (Macintosh; Intel Mac OS X)" }
	end

	def crawl(id)
		initialize_session
		@school = School.find(id)
  	url = @school.crawl_url
	  @session.visit(url)
		if @session.html.match(/headerwrapperdiv/i) || @session.current_url.match(/bwckschd/i)
  		@school.crawl_url = @session.current_url
  		@school.crawl_type = 'portal'
  		@school.save
  		@session.driver.quit
  		crawler = PortalCrawler.new
  		crawler.crawl(id)
  	elsif @session.html.match(/displayFormHTML/i) || @session.current_url.match(/webadvisor/i)
  		@school.crawl_url = @session.current_url
  		@school.crawl_type = 'wa'
  		@school.save
  		@session.driver.quit
  		crawler = WebAdvisorCrawler.new
  		crawler.crawl(id)
  	end
	end
  
end