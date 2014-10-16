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

    inputsList.each do |input|
      vectors.each do |vector|
        @agent.transact do

          # puts "Testing #{input} with \"#{vector}\""

          begin
            Timeout::timeout((1.0*@timeout)/1000.0) {
              input.inject(@agent, vector)
            }
            check_sensitives(results, input, vector)
            check_sanitization(results, input, vector)

          rescue Timeout::Error, Net::ReadTimeout
            results << TestResult.new(input, vector, SLOW)
          rescue Mechanize::ResponseCodeError => e
            pp e
            results << TestResult.new(input, vector, ERROR)
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
        results << TestResult.new(input, vector, SENSITIVE_EXPOSED)
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