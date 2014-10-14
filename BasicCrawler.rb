require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'uri'
require 'net/http'

agent = Mechanize.new
website = 'http://127.0.0.1/dvwa/' #ARGV[0]

page = agent.get(website)

form = page.form()

form.username = 'admin'
form.password = 'password'

agent.submit(form, form.buttons.first)

page = agent.get(website + "vulnerabilities/sqli")

form = page.form()