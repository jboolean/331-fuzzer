require 'optparse'
require 'pp'
require 'set'

require_relative 'crawlers/master'
require_relative 'input_finders/master'


class Fuzzer


  def initialize
    @master_crawler = MasterCrawler.new

    # A set of URIs
    @urls = Set.new
  end

  def self.parse_args
    options = Hash.new

    mode = ARGV.shift

    if !mode || ![:discover, :test].include?(mode.to_sym)
      puts 'Invalid mode. Must specify discover or test.'
      exit
    else
      options[:mode] = mode.to_sym
    end

    optparse = OptionParser.new do |opts|
      opts.banner = '[discover | test] url OPTIONS'
        ' COMMANDS:' +
        '   discover  Output a comprehensive, human-readable list of all discovered inputs to the system. Techniques include both crawling and guessing.' +
        '   test      Discover all inputs, then attempt a list of exploit vectors on those inputs. Report potential vulnerabilities.'

      opts.on('-a', '--custom-auth [APPLICATION]', 
        'Signal that the fuzzer should use hard-coded authentication for a specific application') do |ca|
        options[:custom_auth] = ca
      end

      opts.on('-w', '--common-words FILE', 
        'Newline-delimited file of common words to be used in page guessing and input guessing.') do |filename|
        options[:words_file] = filename
      end

      #TODO: test options in test mode

      opts.on('-h', '--help', 'Display this message.') do
        puts opts
        exit
      end

    end

    optparse.parse!

    options[:url] = ARGV.shift
    unless options[:url]
      puts 'URL not specified.'
      exit
    end

    options

  end

  def fuzz
    options = Fuzzer.parse_args
    crawl(options[:url])

    pp @urls
    # find_inputs()
    # print inputs

  end

  # crawl deeply with the @master_crawler from root, adding to @urls.
  def crawl(root)
    new_urls = @master_crawler.discover_urls(root)

    new_urls.each do |new_url|

      unless @urls.add?(new_url).nil?
        crawl(new_url)
      end

    end
  end

end

fuzzer = Fuzzer.new
fuzzer.fuzz

