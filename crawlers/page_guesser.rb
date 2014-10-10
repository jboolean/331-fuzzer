require 'mechanize'
require 'uri'

require_relative 'crawler'


# Interface for a crawler
class PageGuesser < Crawler

  def initialize(words)
    @extensions = [nil, 'php', 'html', 'jsp', 'action']
    @words = words
  end

  # root: a URI of the root url
  # Get an array of unique URLs available from the root url
  def discover_urls(root)
    # root = URI(root) unless root.is_a? URI

    found_pages = Set.new

    @words.each do |word|
      @extensions.each do |ext|

        guess_path = ext.nil? ? word : "#{word}.#{ext}"
        guess_uri = URI.join(root, guess_path)

        found = true

        begin
          page = $agent.get(guess_uri)
        rescue Mechanize::ResponseCodeError => e
          found = e.response_code.to_i != 404
        end

        found_pages << guess_uri if found

      end
    end

    found_pages
  end

end
