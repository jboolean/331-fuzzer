# Interface for a crawler
class Crawler

  # root: a string of the root url
  # Get an array of unique URLs available from the root url
  def discover_urls(root)
    abstract
  end

  private 

  def abstract
    throw "Abstract method #{__method__} not implemented!"
  end

end