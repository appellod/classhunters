class CrawlerJob
  @queue = :crawl

  def self.perform(id)
    logger = Logger.new('log/crawl.log')
  	crawler = Crawler.new
    school_name = School.find(id).name
    begin
      time = crawler.crawl_school(id)
      logger.info school_name + ": Completed in " + time + " seconds."
    rescue Exception => e
      logger.info school_name + ": " + e.to_s
    end
  end
end