require 'nokogiri'
require 'open-uri'

doc = Nokogiri::HTML(open("http://www.sportsshooter.com/message_display.html?tid=37995"))

comments = doc.xpath("//table[@bgcolor='#696969']")

comments.each do |comment|
  puts comment.content
  puts '-------------------------'
end

puts comments.size
