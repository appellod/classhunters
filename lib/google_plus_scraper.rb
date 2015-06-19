# Add the mixin
require 'capybara_with_phantom_js'

# Google+ Scraper
#
# === Example
#
#   g_plus = GooglePlusScraper.new(111044299943603359137)
#   data = g_plus.to_h
#   # => { id: 111044299943603359137, in_circles: 1234, timestamp: 123456789 }
#
class GooglePlusScraper
  include CapybaraWithPhantomJs

  def initialize(profile_id)
    @profile_id = profile_id
  end

  # Return a hash
  def to_h
    data = {
        :id => @profile_id,
        :in_circles => in_circles,
        :timestamp => Date.today.to_datetime.to_i
    }
  end

  # Return the circle count as an integer
  def in_circles
    matches = tp_tx_hp
    return 0 if matches.nil?
    # Next line Updated by Dan to accomodate Google's changes
    str = matches.find { |s| s.include?('people') }
    (str.nil?) ? 0 : Integer(str.gsub(/,/, '').match(/\d+/)[0])
  end

  # Next line Updated by Dan to accomodate Google's changes
  # Return the text found in span tag with class="d-s r5a"
  def tp_tx_hp
    # Next line Updated by Dan to accomodate Google's changes
    results = google_plus_page.search('//span[contains(@class,"d-s r5a")]')
    results = results.collect(&:text)
    return nil if results.empty?
    results
  end

  # Get the Google Plus page and locally cache it in an instance variable
  def google_plus_page
    unless @google_plus_page
      new_session
      # Next line Updated by Dan 
      @session.visit "https://plus.google.com/u/0/#{@profile_id}/posts"
      sleep 5 # give phantomjs 5 seconds and let the page fill itself in
      @google_plus_page = Nokogiri::HTML.parse(html)
    end
    @google_plus_page
  end

end