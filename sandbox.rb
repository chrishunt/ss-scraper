require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open("http://www.sportsshooter.com/message_display.html?tid=38056"))

comments = doc.xpath("//img[@height='50']")

comments.each do |comment|
  puts comment[:src]
  puts '-------------------------'
end

puts comments.size
