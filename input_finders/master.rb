require_relative 'input_finder'
require_relative 'get_param_finder'
require_relative 'form_param_finder'

# An input finder that aggregates the results of all the other input finders
class MasterInputFinder < InputFinder

  def initialize
    @input_finders = [GETParamInputFinder.new, FormParamInputFinder.new]
  end

  # Call all the input finders and aggregate the results
  # return a set of Inputs
  def discover_inputs(url)
    @inputs = Set.new
    @input_finders.each do |input_finder|
      @inputs.merge input_finder.discover_inputs(url)
    end
    return @inputs
  end

end