require_relative 'crawler'

# A crawler that aggregates the results of all the other Crawlers
class MasterCrawler < Crawler

  # Call all the crawlers and aggregate the results
  # return a set of urls
  def discover_urls(root)
    throw 'not implemented. implement me'
  end

end