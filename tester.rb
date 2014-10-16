require 'timeout'
require 'pp'

require_relative 'test_result'

class FuzzTester
  include ResultTypeEnum

  # characters that should be escaped
  SHOULD_SANITIZE = ['<', '>']

  def initialize(agent, sensitives, timeout)
    @agent = agent
    @sensitives = sensitives
    @timeout = timeout
  end

  def test(inputs, vectors, isRandom=false)

    results = Set.new

    inputsList = []
    if isRandom
      inputsList = inputs.to_a.shuffle
    else
      inputsList = inputs.to_a.sort_by {|i| i.uri}
    end

    @agent.read_timeout = 1000;

    inputsList.each do |input|
      vectors.each do |vector|
        @agent.transact do

          # puts "Testing #{input} with \"#{vector}\""

          begin
            pageResult = Timeout::timeout((1.0*@timeout)/1000.0) {
              input.inject(@agent, vector)
            }
            check_sensitives(results, input, vector)
            check_sanitization(results, input, vector)

          rescue Timeout::Error
            results << TestResult.new(input, vector, SLOW)
          rescue Mechanize::ResponseCodeError => e
            results << TestResult.new(input, vector, ERROR, e.response_code) if e.response_code != 404
          rescue Exception => e
            puts "ERROR: An unexpected error (#{e.class}) occured while testing input #{input} with vector #{vector}: #{e}"
            pp e.backtrace
          end

        
        end
      end
    end

    return results

  end

  private

  def check_sensitives(results, input, vector)
    pageContent = @agent.page.content.downcase

    @sensitives.each do |sensitive_datum|
      if pageContent.include? sensitive_datum.downcase
        results << TestResult.new(input, vector, SENSITIVE_EXPOSED, "\"#{sensitive_datum}\"")
      end
    end
  end

  # registers an error if the vector contains < or > and the vector was echoed on the page. 
  # A standalone < is a bad vector.
  def check_sanitization(results, input, vector)
    unless SHOULD_SANITIZE.reduce(false) {|memo, escapable| memo || vector.include?(escapable)}
      # vector doesnt have any escapable characters
      return
    end

    pageContent = @agent.page.content.downcase

    if pageContent.include? (vector.downcase)
      results << TestResult.new(input, vector, NO_SANITIZE)
    end

  end


end