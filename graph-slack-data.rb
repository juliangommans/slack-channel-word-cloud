require 'fileutils'
require 'json'

days = ARGV[0] || 1
folder = File.dirname(__FILE__) + "/logs/official/#{days}"
@frequency_array = []

puts "GETTING FOLDERS"
directories = Dir.entries(folder).select {|entry| File.directory? File.join(folder,entry) and !(entry =='.' || entry == '..') }

@word_hash = Hash.new
def build_word_hash(file, i)
  file.each do |line|
    items = line.split ": "
    unless @word_hash[items[0]].nil?
      @word_hash[items[0]][i] = items[1].to_i
    else
      @word_hash[items[0]] = {"#{i}" => items[1].to_i}
    end
  end
end

def plug_the_holes(i)
  @word_hash.each do |k,v|
    @word_hash[k][i] = 0 if @word_hash[k][i].nil? && i != 0
  end
end

i = 0
directories.each do |dir|
  text = File.read(folder + "/" + dir + "/words.txt").split("\n")
  build_word_hash(text, i)
  plug_the_holes(i)
  i += 1
end

@word_hash.each do |k,v|
  tot = 0
  @word_hash[k].each do |_k, _v|
    tot += @word_hash[k][_k]
  end
  @word_hash[k]["name"] = k
  @word_hash[k]["total"] = tot
end

@sorting_ary = []

@word_hash.each do |k,v|
  @sorting_ary.push(@word_hash[k])
end

sorted = @sorting_ary.sort_by { |k,v| k["total"] }

new_hash = Hash.new

sorted.last(10).each do |item|
  new_hash[item["name"]] = item
end

new_hash.each do |k,v|
  new_hash[k].delete("name")
  new_hash[k].delete("total")
end

puts new_hash

jason = new_hash.to_json

puts jason

File.open(File.dirname(__FILE__) + "/graph_page/assets/json/graph_data.json", "w") { |f| f.write "data = '#{jason}'" }
