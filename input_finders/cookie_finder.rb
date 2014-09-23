require_relative 'input_finder'
require 'mechanize'
require 'pp'

# An input finder that finds GET parameters on a URL
class CookieFinder < InputFinder

  #def initialize
  #  @agent = Mechanize.new
  #end

  # Call all the input finders and aggregate the results
  # return a set of Inputs
  def discover_inputs(root)	
    inputs = Set.new
    $agent.cookies.each do |cookie|
	  inputs << CookieInput.new(cookie.origin, cookie.name, cookie.value)
    end
    inputs

  end

end
