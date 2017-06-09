require 'http'
require 'json'
require 'magic_cloud'
# require 'pry'
require 'slack-ruby-client'
require 'fileutils'

token = "" #insert slack channel api token
logs = []

def log_and_put(msg,logs)
  puts msg
  logs.push(msg)
end

rewind = ARGV[0] || 7 # default one week
logs.push("Todays datetime (#{Time.now})")
if rewind.to_i < 3
  hours_ago = Time.now - (rewind.to_i*24).hours
  from = hours_ago.to_i
  logs.push("Getting time in hours ago (#{hours_ago})")
else
  days_ago = (Date.today - rewind.to_i).to_time
  from = days_ago.to_i
  logs.push("Getting time in days ago (#{days_ago})")
end

channel_name = ARGV[1] || "jules-testing" # default test channel
output_channel = ARGV[2] || channel_name

log_and_put("Finding channel #{channel_name} and output channel #{output_channel} id(s)", logs)

# channel logix for modular channeling

def fetch_channel_id(name, token)
  channel_url = "https://slack.com/api/channels.list?token=#{token}&pretty=1"
  r = HTTP.get(channel_url)
  j = JSON.parse(r)
  channels = j["channels"]
  ch_search = channels.select { |c| c["name"] == name }[0]
  ch_search.nil? ? "C4P3DTTL7" : ch_search["id"]
end

channel_id = fetch_channel_id(channel_name, token)
output_id = fetch_channel_id(output_channel, token)

log_and_put("Channel: #{channel_name}, id: #{channel_id}", logs)
log_and_put("Output_channel: #{output_channel}, id: #{output_id}", logs)
# channel_name = ch_search.nil? ? channel_name : ch_search["name"]
# channel_id = ch_search.nil? ? "C4P3DTTL7" : ch_search["id"]


### channel ids:
# jules-testing = C4P3DTTL7
# tech-check-in = C4JC40NHE
# general = C026MQS9V
# web-team = C07L5RT3Q

messages = []

def wordcloud_string(f)
  f = f.to_i
  return "year" if f/365 == 1
  return "#{f/365} years" if f/365 > 1
  return "#{f*24} hours" if f < 3
  return "#{f} days" if f > 2 && f % 7 != 0
  return "1 week" if f == 7
  return "#{f/7} weeks" if f % 7 == 0
end

count = 0
while true do
  count += 1
  url = "https://slack.com/api/channels.history?token=#{token}&channel=#{channel_id}&oldest=#{from}&count=100&pretty=1"
  log_and_put("Requesting messages (#{count})", logs)
  resp = HTTP.get(url)
  json = JSON.parse(resp)
  messages += json['messages']
  from = json['messages'].first['ts']
  log_and_put("Fetching more messages", logs) if json["has_more"]
  break unless json["has_more"]
end

message_count = messages.count
log_and_put("Fetched #{message_count} messages", logs)
log_and_put("Removing newlines and limiting character set", logs)
cleaned = messages.select {|f| f['subtype'].nil? }.map {|f| f['text'].downcase.gsub("\n", " ").gsub(/[^a-z ]/i, ' ') }
File.open(File.dirname(__FILE__) + "/cleaned.txt", "w") {|f| f.write cleaned.join("\n") }

bad_words = File.read(File.dirname(__FILE__) + "/stopwords.txt").split("\n")
log_and_put("Cleaning", logs)
words = Hash.new(0)

cleaned.join(" ").split(" ").reject{|word| word.length <= 2 }.reject {|word| bad_words.include?(word) }.each {|word| words[word] += 1 }


sorted = words.sort_by {|k| -k[1] }.take(100)

sorted = [["filler1", 1], ["filler4", 1], ["ss2small", 3], ["nothing", 4], ["ubrokeit", 5], ["=(", 4], ["filler2", 1], ["filler3", 1]] if sorted.length  < 1

File.open(File.dirname(__FILE__) + "words.txt", "w") { |f| f.write sorted.map{|k,v| "#{k}: #{v}" }.join("\n") }

# Word Cloud building logic
cloud = MagicCloud::Cloud.new(sorted, rotate: :none, scale: :sqrt)
log_and_put("Drawing word cloud", logs)
cloud.draw(550, 550).write(File.dirname(__FILE__) + "/wordcloud.jpg")

# Slack logic for sending the word cloud to THEE slack
log_and_put("Sending it up to slackaroony", logs)
Slack.configure do |config|
  config.token = token
end
client = Slack::Web::Client.new
client.files_upload(
  channels: output_id,
  as_user: false,
  file: Faraday::UploadIO.new(File.dirname(__FILE__) + '/wordcloud.jpg', 'image/jpeg'),
  title: "#{channel_name} WordCloud for past #{wordcloud_string(rewind)} (and #{message_count} messages)",
  filename: 'wordcloud.jpg'
)

# Logging results
log_directory = "#{channel_name}-#{Time.now.to_s.split[0]}-#{Time.now.to_i}"
log_and_put("Creating log folders", logs)
base_folder = "/logs/official"
duration_folder = "/#{base_folder}/#{rewind}"
Dir.mkdir(File.dirname(__FILE__) + duration_folder) unless Dir.exists?(File.dirname(__FILE__) + duration_folder)
channel_folder = "/#{duration_folder}/#{log_directory}"
Dir.mkdir(File.dirname(__FILE__) + channel_folder)
# log_and_put("Adding image to log folder", logs)
# FileUtils.cp(File.dirname(__FILE__) + "./wordcloud.jpg", File.dirname(__FILE__) + folder)
log_and_put("Adding words file to log folder", logs)
File.open(File.dirname(__FILE__) + "#{channel_folder}/words.txt", "w") { |f| f.write sorted.map{|k,v| "#{k}: #{v}" }.join("\n") }
log_and_put("Creating and adding logs file to log folder", logs)
File.open(File.dirname(__FILE__) + "#{channel_folder}/logs_files.txt", "w") { |f| f.write logs.join("\n") }
