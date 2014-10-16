module ResultTypeEnum
  SLOW = 0
  ERROR = 1
  SENSITIVE_EXPOSED = 2
  NO_SANITIZE = 3

  ERROR_DESCRIPTIONS = {
    SLOW => 'The response timed out',
    ERROR => 'An HTTP error occured',
    SENSITIVE_EXPOSED => 'Sensitive data was exposed',
    NO_SANITIZE => 'The vector was found unsanitized in the response'
  }.freeze
end

class TestResult
  include ResultTypeEnum

  attr_reader :input
  attr_reader :value
  attr_reader :type

  def initialize(input, value, type)
    @input = input
    @value = value
    @type = type
  end

  def to_s
    "#{ERROR_DESCRIPTIONS[@type]} when \"#{@value}\" was injected into #{@input}"
  end

end