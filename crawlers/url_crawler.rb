require 'mechanize'
require 'uri'

require_relative 'crawler'


# Interface for a crawler
class URLCraweler < Crawler

  # root: a URI of the root url
  # host: the website to stay on
  # Get an array of unique URLs available from the root url
  def discover_urls(root)
    puts "Crawling #{root.to_s}"

    unless root.is_a? URI
      root = URI(root)
    end

    begin
      page = $agent.get(root)
      # root = page.canonical_uri
    rescue Mechanize::ResponseCodeError => e
      #puts e
      return Set.new
    end

    resolved_uris = page.links
      .keep_if {|l| !l.uri.nil?}
      .map {|l| URI.join(root.to_s , l.uri) }

    #don't go off the domain or include duplicates
    Set.new resolved_uris.keep_if {|uri| uri.host == root.host}
  end
end
