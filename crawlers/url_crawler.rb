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
  def discover_urls(root)
    puts "Crawling #{root.to_s}"
    root = URI(root) unless root.is_a? URI

    begin
      page = $agent.get(root)
      root = page.canonical_uri
    rescue Mechanize::ResponseCodeError => e
      #puts e
      return Set.new
    end

    #calling page.canonical_uri sets root to nil which cause URI.join to error out.
    #Hard coding value to avoid this error for now.
    root = URI('http://127.0.0.1/dvwa')

    #page.links.each do |link|
    #  puts link.uri
    #end

    resolved_uris = page.links
      .keep_if {|l| !l.uri.nil?}
      .map {|l| URI.join(root, l.uri) }

    Set.new resolved_uris.keep_if {|uri| uri.host == root.host} #don't go off the domain
  end


end
