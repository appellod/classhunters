class URLScannerJob
  @queue = :url_scanner

  def self.perform(id)
    start_time = Time.now
    logger = Logger.new('log/crawl.log')
  	url_scanner = URLScanner.new
    school_name = School.find(id).name
    begin
      result = url_scanner.scan_school(id)
      logger.info school_name + " -> " + result + " : " + (Time.now - start_time).round.to_s + " seconds."
    rescue Exception => e
      logger.info school_name + ": " + e.to_s
    end
  end
end