require 'scrapi'
require 'open-uri'

HTML_NAME = 'messages.html'

# download html and convert to UTF-8
html = ""
html << open("http://www.sportsshooter.com/message_index.html").read.gsub('iso-8859-1','UTF-8')

# scrape content
scraper = Scraper.define do
  array :tables
  process 'table', :tables => Scraper.define {
    array :rows
    process 'tr', :rows => Scraper.define {
      array :columns
      process 'td', :columns => :text
      result :columns
    }
    result :rows
  }
  result :tables
end

results = scraper.scrape(html)
puts results[1].first.first.first.size
