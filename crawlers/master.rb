require_relative 'crawler'
require_relative 'url_crawler'

# A crawler that aggregates the results of all the other Crawlers
class MasterCrawler < Crawler

  def initialize
    @crawlers = [URLCraweler.new]
  end

  # Call all the crawlers and aggregate the results
  # return a set of URIs
  def discover_urls(root)
    @urls = Set.new
    @crawlers.each do |crawler|
      @urls.merge crawler.discover_urls(root)
    end
    return @urls
  end

end