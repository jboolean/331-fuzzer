require 'mechanize'
require 'uri'

require_relative 'crawler'


# Interface for a crawler
class URLCraweler < Crawler

  #def initialize
  #  @agent = Mechanize.new
  #end

  # root: a URI of the root url
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
      #root = page.canonical_uri
    rescue Mechanize::ResponseCodeError => e
      #puts e
      return Set.new
    end

    #calling page.canonical_uri sets root to nil which cause URI.join to error out.
    #Hard coding value to avoid this error for now.
    #rootLocal = URI('http://127.0.0.1/dvwa/')

    resolved_uris = page.links
      .keep_if {|l| !l.uri.nil?}
      .map {|l| URI.join(rootLocal.to_s , l.uri) }

    #don't go off the domain or include duplicates
    Set.new resolved_uris.keep_if {|uri| uri.to_s.include? host}
  end
end
