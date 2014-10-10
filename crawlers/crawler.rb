require 'set'

# Interface for a crawler
class Crawler

  # root: a URI of the root url
  # host: the website to stay on
  # Get an array of unique URLs available from the root url
  def discover_urls(root, host)
    abstract
  end

  private 

  def abstract
    throw "Abstract method #{__method__} not implemented!"
  end

end