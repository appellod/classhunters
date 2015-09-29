class CrawlerJob
  @queue = :crawl

  def self.perform(id)
    start_time = Time.now
    logger = Logger.new("#{Rails.root}/log/crawl.log")
  	crawler = Crawler.new
    school_name = School.find(id).name
    begin
      result = crawler.crawl(id)
      logger.info school_name + " -> " + result + " : " + (Time.now - start_time).round.to_s + " seconds."
    rescue Exception => e
      logger.info school_name + "(#{id}): " + School.find(id).crawl_type + ": " + e.to_s
    end
  end
end