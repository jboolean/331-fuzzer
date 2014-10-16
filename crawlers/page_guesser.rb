require 'mechanize'
require 'uri'

require_relative 'crawler'


# Interface for a crawler
class PageGuesser < Crawler

  def initialize(words)
    @suffixes = ['', '.php', '.html', '.jsp', '.action']
    @words = words
  end

  # roots an Enumerable of paths to join onto
  def discover_urls(roots)

    attempted = Set.new

    found_pages = Set.new

    roots.each do |root|
      @words.each do |word|
        @suffixes.each do |suffix|

          guess_uri = URI.join(root, "#{word}#{suffix}")
          next if attempted.add(guess_uri).nil?

          found = true

          $agent.transact do

            begin
              # puts "Attempting  #{guess_uri}"
              $agent.get(guess_uri)
            rescue Mechanize::ResponseCodeError => e
              found = e.response_code.to_i != 404
            end

            found_pages << guess_uri if found
          end
        end
      end
    end

    found_pages
  end

end
