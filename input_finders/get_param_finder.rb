require_relative 'input_finder'
require 'uri/query_params'

# An input finder that finds GET parameters on a URL
class GETParamInputFinder < InputFinder

  # Call all the input finders and aggregate the results
  # return a set of Inputs
  def discover_inputs(root)
    root = URI(root) unless root.is_a?(URI)

    inputs = Set.new

    root.query_params.each do |k, v|
      inputs << HTTPParamInput.new(root, k, :GET)
    end

    inputs

  end

end