require 'mechanize'
require 'uri'

require_relative 'crawler'


# Interface for a crawler
class URLCraweler < Crawler

  def initialize
    @agent = Mechanize.new
  end

  # root: a URI of the root url
  # Get an array of unique URLs available from the root url
  def discover_urls(root)
    root = URI(root) unless root.is_a? URI

    begin
      page = @agent.get(root)
      root = page.canonical_uri
    rescue Mechanize::ResponseCodeError => e
      puts e
      return Set.new
    end

    resolved_uris = page.links
      .keep_if {|l| !l.uri.nil?}
      .map {|l| URI.join(root, l.uri) }

    Set.new resolved_uris.keep_if {|uri| uri.host == root.host}
  end


end