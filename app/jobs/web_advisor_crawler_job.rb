class WebAdvisorCrawlerJob
  @queue = :crawl_web_advisor

  def self.perform(id)
    start_time = Time.now
    logger = Logger.new('log/crawl.log')
  	crawler = WebAdvisorCrawler.new
    school_name = School.find(id).name
    begin
      result = crawler.crawl(id)
      logger.info school_name + " -> " + result + " : " + (Time.now - start_time).round.to_s + " seconds."
    rescue Exception => e
      logger.info school_name + ": " + e.to_s
    end
  end
end