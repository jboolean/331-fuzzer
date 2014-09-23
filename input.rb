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
  def to_s
    "GET url parameter on #{uri} with key=#{@key}, defaulted to #{@initial_value}"
  end
end

class FormFieldInput < Input
  attr_reader :method
  attr_reader :type
  attr_reader :on_url

  def initialize(uri, key, initial_value, field_type, method, on_url)
    super(uri, key, initial_value)
    @method = method
    @field_type = field_type
    @on_url = on_url
  end

  def to_s
    "#{@method} #{key} to #{@uri} from #{@on_url}. Defaulted to \"#{@initial_value}\" from a #{@field_type} field."
  end
end