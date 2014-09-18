require_relative 'input_finder'

# A crawler that aggregates the results of all the other Crawlers
class MasterInputFinder < InputFinder

  # Call all the input finders and aggregate the results
  # return a set of Inputs
  def discover_inputs(root)
    throw 'not implemented yet. implement me'
  end

end