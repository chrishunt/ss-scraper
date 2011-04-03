require 'nokogiri'
require 'open-uri'

OUTPUT_FILE = 'output.html'
BASE_URL = 'http://www.sportsshooter.com'
MAX_TOPICS = 20

file = File.open(OUTPUT_FILE, 'w')
file.write("
<!DOCTYPE html>
<html>
  <head>
    <title>Sports Book</title>
    <link rel='stylesheet' type='text/css' href='style.css' />
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

topics.each_with_index do |topic, index|
  topic_name = topic.content.strip
  topic_url = "#{BASE_URL}#{topic[:href]}"

  file.write("<div class='topic' id='topic_#{index}'><h1>#{topic_name}</h1>")

  print "(#{index+1}/#{MAX_TOPICS}) Loading comments for topic: #{topic_name}... "
  doc = Nokogiri::HTML(open(topic_url))
  comments = doc.xpath("//table[@bgcolor='#696969']")
  avatars = doc.xpath("//img[@height='50']")
  puts "done"
  puts "#{comments.size} comments found.\n\n"

  file.write("<p class='topic_controls'>")
  if index > 0
    file.write("<a href='#topic_#{index-1}'><<</a>")
  else
    file.write("<<")
  end
  file.write("<a class='comment_count' href='#{topic_url}' target='blank'>#{comments.size} comment#{'s' if comments.size > 1}</a>")
  if index < MAX_TOPICS-1
    file.write("<a href='#topic_#{index+1}'>>></a>")
  else
    file.write(">>")
  end
  file.write("</p>")

  comments.each_with_index do |comment, index|
    lines = []
    comment.content.gsub('->>','').strip.each_line do |line|
      lines << line.strip
    end
    file.write("<p>")
    file.write("<span class='comment_title'>")
    avatar = avatars[index][:src]
    file.write("<a href='#{BASE_URL}/#{avatar.split('/')[1]}' target='blank'><img src='#{BASE_URL}#{avatar}' /></a>")
    file.write("<span class='username'>#{lines[0].strip}</span> | ")
    lines[1].split("|").each_with_index do |title_fragment, index|
      file.write("<span class='fragment_#{index}'> #{title_fragment.strip}</span>")
    end
    file.write("</span>")
    lines[2..lines.size-2].each do |line|
      line.strip.split.each do |word|
        is_link = word.include?('http://')
        file.write("#{"<a href='#{word}' target='blank'>" if is_link}#{word}#{"</a>" if is_link} ")
      end
      file.write("<br/>")
      file.write("<br/>")
    end
    file.write("</p>")
  end

  file.write("</div>")
end

file.write("
</div>
</body>
</html>")
file.close

puts "Output writen to: #{OUTPUT_FILE}\n\n"
puts "Done."
