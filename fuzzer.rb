require 'optparse'
require 'pp'
require 'set'

require_relative 'crawlers/url_crawler'
require_relative 'crawlers/page_guesser'
require_relative 'input_finders/master'
require_relative 'input'
require_relative 'authenticator'
require_relative 'tester'


class Fuzzer


  def initialize
    $agent = Mechanize.new
    $possibleVulnerabilities = Set.new
    @master_crawler = URLCrawler.new
    @master_input_finder = MasterInputFinder.new

    # A set of URIs
    $urls = Set.new

    @inputs = Set.new
  end

  def self.parse_args
    options = {
      :random => false,
      :slow => 1500
    }

    mode = ARGV.shift

    if !mode || ![:discover, :test].include?(mode.to_sym)
      puts 'Invalid mode. Must specify discover or test.'
      exit 1
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

      opts.on('-w', '--common-words=FILE', 
        'Newline-delimited file of common words to be used in page guessing and input guessing.') do |filename|
        options[:words_file] = filename
      end

      if options[:mode] == :test

        opts.on('--vectors=FILE',
          'Newline-delimited file of common exploits to vulnerabilities.') do |filename|
          options[:vector_file] = filename
        end

        opts.on('--sensitive=FILE',
          'Newline-delimited file data that should never be leaked. Its assumed that this data is in the applications database (e.g. test data), but is not reported in any response.') do |filename|
          options[:sensitive_file] = filename
        end

        opts.on('--random', 'When off, try each input to each page systematically.  When on, choose a random page, then a random input field and test all vectors. Default: false.') do |isRandom|
          options[:random] = isRandom
        end

        opts.on('--slow TIMEOUT', Numeric, 'Number of milliseconds considered when a response is considered "slow". Default is 500 milliseconds') do |slowVal|
          options[:slow] = slowVal
        end
      end

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

  public 

  def fuzz
    @options = Fuzzer.parse_args

    unless @options[:custom_auth].nil?
      CustomAuthenticator.authenticate(@options[:custom_auth].to_sym, $agent)
    end

    discover()

    if @options[:mode] == :test
      test()
    end

  end

  private


  def discover

    #crawl_word_list(@options[:url])

    crawl(@options[:url])

    print_header('Links')

    $urls.each {|url| puts url}

    $urls.each do |url|
      unless url.to_s.include? 'logout'
        find_inputs(url)
      end
    end

    print_header('Inputs')

    @inputs.each {|input| puts input}
  end

  def test
    vectors = readlines_and_clean(@options[:vector_file])
    sensitives = readlines_and_clean(@options[:sensitive_file])

    tester = FuzzTester.new($agent, sensitives, @options[:slow])
    testResults = tester.test(@inputs, vectors, @options[:random])

    print_header('Possible Attack Vectors')
    testResults.each {|r| puts r}

  end

  def crawl_word_list(root)
    words = readlines_and_clean(@options[:words_file])
    words.each {|word| word.strip!}

    guesser = PageGuesser.new(words)

    $urls.merge(guesser.discover_urls(root))
  end


  # crawl deeply with the @master_crawler from root, adding to @urls.
  def crawl(root)
    root = URI(root) unless root.is_a?(URI)
    $urls << root

    new_urls = @master_crawler.discover_urls(root)

    new_urls.each do |new_url|

      unless $urls.add?(new_url).nil?
        if !new_url.to_s.include? 'logout'
          crawl(new_url)
        end

      end

    end
  end

  def find_inputs(root)
    @inputs.merge(@master_input_finder.discover_inputs(root))
  end

  def readlines_and_clean(file)
    File.readlines(file)
    .map {|l| l.strip}
    .keep_if {|l| !l.empty?}
  end

  def print_header(message)
    puts "\n#{message}\n#{'='*5}"
  end



end

fuzzer = Fuzzer.new
fuzzer.fuzz
