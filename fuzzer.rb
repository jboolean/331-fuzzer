require 'optparse'
require 'pp'
require 'set'

require_relative 'crawlers/master'
require_relative 'crawlers/page_guesser'
require_relative 'input_finders/master'
require_relative 'input'


class Fuzzer


  def initialize
    $agent = Mechanize.new
    @master_crawler = MasterCrawler.new
    @master_input_finder = MasterInputFinder.new

    # A set of URIs
    $urls = Set.new

    @inputs = Set.new
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
    @options = Fuzzer.parse_args

    case @options[:custom_auth]
    when nil
      # continue
    when 'dvwa'
      loginDVWA
    when 'bodgit'
      loginBodgeIt
    else
      puts "Not a valid authentication type: #{@options[:custom_auth]}"
      exit      
    end

    #crawl_word_list(@options[:words_file])

    crawl(@options[:url])

    puts "\n"*5

    puts 'Links'
    $urls.each {|url| puts url}

    puts "\n"*5

    $urls.each {|url| find_inputs(url)}

    puts 'Inputs'
    @inputs.each {|input| puts input}

    #puts 'Cookies'
    #$agent.cookies.each{|cookie| pp cookie}
  end

  def crawl_word_list(root)
    words = File.readlines(@options[:words_file])
    words.each {|word| word.strip!}

    guesser = PageGuesser.new(words)

    $urls.merge(guesser.discover_urls(root))
  end

  def loginDVWA
    page = $agent.get('http://127.0.0.1/dvwa/')

    form = page.form()
	
    form.username = 'admin'
    form.password = 'password'

    $agent.submit(form, form.buttons.first)
  end

  def loginBodgeIt
    page = $agent.get('http://127.0.0.1:8080/bodgeit/login.jsp')

    form = page.form()

    #Not sure what the actual name and password are.
    form.username = 'admin'
    form.password = 'password'

    $agent.submit(form, form.buttons.first)
  end

  # crawl deeply with the @master_crawler from root, adding to @urls.
  def crawl(root)
    root = URI(root) unless root.is_a?(URI)
    $urls << root

    new_urls = @master_crawler.discover_urls(root, @options[:url])

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

end

fuzzer = Fuzzer.new
fuzzer.fuzz

