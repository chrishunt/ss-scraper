require 'nokogiri'
require 'open-uri'

OUTPUT_FILE = 'html/index.html'
BASE_URL = 'http://www.sportsshooter.com'
MAX_TOPICS = 10

file = File.open(OUTPUT_FILE, 'w')
file.write("
<!DOCTYPE html>
<html>
  <head>
    <title>Sports Book</title>
    <link rel='stylesheet' type='text/css' href='style.css' />
    <meta content='text/html; charset=utf-8' http-equiv='Content-Type'>
  </head>
<body>
<div id='container'>
<div id='header'>
  Sports Book
</div>")

puts "Max topics set to: #{MAX_TOPICS}\n\n"

url = "#{BASE_URL}/message_index.html"
print "Loading topics from: #{url}... "
doc = Nokogiri::HTML(open(url))
puts "done"

topics = doc.css('html body table tr td table tr td table tr td a')
topics = topics[2..topics.size-2]
topics = topics[0..MAX_TOPICS-1]
puts "#{topics.size} topics found.\n\n"

# Iterate through each topic
topics.each_with_index do |topic, index|
  topic_name = topic.content.strip
  topic_url = "#{BASE_URL}#{topic[:href]}"

  file.write("\n\n<div class='topic' id='topic_#{index}'>\n<h1>#{topic_name}</h1>\n")

  print "(#{index+1}/#{MAX_TOPICS}) Loading comments for topic: #{topic_name}... "
  doc = Nokogiri::HTML(open(topic_url))
  comments = doc.xpath("//table[@bgcolor='#696969']")
  avatars = doc.xpath("//img[@height='50']")
  puts "done"
  puts "#{comments.size} comments found.\n\n"

  file.write("<p class='topic_controls'>\n")
  if index > 0
    file.write("\t<a href='#topic_#{index-1}'>&lt;&lt;</a>")
  else
    file.write("\t&lt;&lt;")
  end
  file.write("\n\t<a class='comment_count' href='#{topic_url}' target='blank'>\n\t\t#{comments.size} comment#{'s' if comments.size > 1}\n\t</a>")
  if index < MAX_TOPICS-1
    file.write("\n\t<a href='#topic_#{index+1}'>>></a>")
  else
    file.write("\n\t>>")
  end
  file.write("\n</p>\n")

  # Place newer comments on top (reverse of SportsShooter.com)
  comments = comments.reverse
  avatars = avatars.reverse

  # Iterate through each comment
  comments.each_with_index do |comment, index|
    lines = []
    comment.content.gsub('->>','').gsub('&','&amp;').strip.each_line do |line|
      lines << line.strip
    end
    file.write("<p>\n")
    file.write("\t<span class='comment_title'>\n")
    avatar = avatars[index][:src]
    file.write("\t\t<a href='#{BASE_URL}/#{avatar.split('/')[1]}' target='blank'>\n\t\t\t<img src='#{BASE_URL}#{avatar}' alt='avatar'/>\n\t\t</a>\n")
    file.write("\t\t<span class='username'>#{lines[0].strip}</span> | \n")
    lines[1].split("|").each_with_index do |title_fragment, index|
      file.write("\t\t<span class='fragment_#{index}'> #{title_fragment.strip}</span>\n")
    end
    file.write("\t</span>\n")
    lines[2..lines.size-2].each do |line|
      line.strip.split.each do |word|
        link = word.match(Regexp.new 'http://.*')
        if !link.nil?
          link = link.to_s
          word = word.gsub(link,'')
        end
        file.write("#{word} ")
        file.write("<a href='#{link}' target='blank'>#{link}</a> ") unless link.nil?
      end
      file.write("<br /><br />\n")
    end
    file.write("</p>\n")
  end

  file.write("</div>\n")
end

file.write("
</div>
</body>
</html>")
file.close

puts "Output writen to: #{OUTPUT_FILE}\n\n"
puts "Done."
