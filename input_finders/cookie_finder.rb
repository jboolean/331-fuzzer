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
    jar = $agent.cookie_jar.jar
    inputs = Set.new
    jar.each do |cookie|
      inputs << CookieInput.new(nil, cookie.name, cookie.value)
    end
    # TODO: Create inputs from cookies
    Set.new

  end

end
