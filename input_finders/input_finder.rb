# Interface for an input finder
class InputFinder

  # url: a string of the  url
  # Get an array of unique URLs available from the root url
  def discover_inputs(url)
    abstract
  end

  private 

  def abstract
    throw "Abstract method #{__method__} not implemented!"
  end

end