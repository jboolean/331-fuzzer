require 'mechanize'
require 'uri'

require_relative 'crawler'


# Interface for a crawler
class URLCrawler < Crawler

  # root: a URI of the root url
  # host: the website to stay on
  # Get an array of unique URLs available from the root url
  def discover_urls(root, host)
    puts "Crawling #{root.to_s}"

    if root.is_a? URI
      rootLocal = root
    else
      rootLocal = URI(root)
    end

    begin
      page = $agent.get(rootLocal)
      # root = page.canonical_uri
    rescue Mechanize::ResponseCodeError => e
      puts e
      return Set.new
    end

    resolved_uris = page.links
      .keep_if {|l| !l.uri.nil?}
      .map {|l| URI.join(page.uri.to_s , l.uri) }

    #don't go off the domain or include duplicates
    Set.new resolved_uris.keep_if {|uri| uri.to_s.start_with? host}.keep_if {|uri| !$urls.include? uri}
  end
end
