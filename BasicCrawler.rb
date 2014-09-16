require 'rubygems'
require 'mechanize'

agent = Mechanize.new
links = Hash.new
website = ARGV[0]

puts website

page = agent.get(website)

page.links.each do |link|
	links[link.text] = link.uri
end

links.each do |key, value|
	puts key
	puts value
end
