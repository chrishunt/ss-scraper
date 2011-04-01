require 'nokogiri'
require 'open-uri'

BASE_URL = 'http://www.sportsshooter.com'
doc = Nokogiri::HTML(open("#{BASE_URL}/message_index.html"))

topics = doc.css('html body table tr td table tr td table tr td a')
topics = topics[2..topics.size-2]
# limit to 10 topics
topics = topics[0..9]

topics.each do |topic|
  topic_name = topic.content.strip
  topic_url = "#{BASE_URL}#{topic[:href]}"

  puts topic_name

  doc = Nokogiri::HTML(open(topic_url))
  comments = doc.xpath("//table[@bgcolor='#C0C0C0']")
  comments = comments[0..comments.size-2]

  puts "#{comments.size} comments.\n-----"

  comments.each do |comment|
    puts comment.content.strip
    puts "-----"
  end
  puts "*******************************"
end
