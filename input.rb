#intended to be subclassed by specific kinds of inputs
class Input
  attr_reader :uri
  # attr_reader :type
  attr_reader :key
  attr_reader :initial_value

  def initialize(uri, key, initial_value)
    @uri = uri
    # @type = type
    @key = key
    @initial_value = initial_value
  end

  # Override to provide better human readable description of
  def to_s
    {:type => self.class.name, :uri => uri, :key => key, :initial_value => initial_value}.to_s
  end

end

class GETParamInput < Input
end