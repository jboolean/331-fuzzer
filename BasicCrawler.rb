require 'rubygems'
require 'mechanize'
require 'open-uri'

agent = Mechanize.new
links = Hash.new
website = 'http://127.0.0.1/dvwa' #ARGV[0]

puts website

page = agent.get(website)

form = page.form()

form.username = 'admin'
form.password = 'password'

page = agent.submit(form, form.buttons.first)
#pp page

agent.cookies.each do |cookie|
	pp cookie
end

page.links.each do |link|
	links[link.text] = link.uri
end

#links.each do |key, value|
#	puts key
#	puts value
#end
