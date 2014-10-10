require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'uri'

agent = Mechanize.new
website = 'http://127.0.0.1/dvwa' #ARGV[0]

root = URI(website) unless root.is_a? URI
pp root

page = agent.get(website)

form = page.form()

form.username = 'admin'
form.password = 'password'

page = agent.submit(form, form.buttons.first)
#pp page

#agent.cookies.each do |cookie|
#	pp cookie
#end

#page = agent.get('http://127.0.0.1/dvwa/instructions.php')

#page.links.each do |link|
	#link = URI.join(root.to_s << '/', link.uri.to_s)
#	pp link.uri
#end

page = agent.get(website << '/logout.php')
pp page

puts '/n'*5

page = agent.get(website << '/index.php')

pp page

#links.each do |key, value|
#	puts key
#	puts value
#end
