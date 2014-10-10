#intended to be subclassed by specific kinds of inputs
class Input
  attr_reader :uri
  # attr_reader :type
  attr_reader :key

  def initialize(uri, key)
    @uri = uri
    # @type = type
    @key = key
  end

  # Override to provide better human readable description of
  def to_s
    {:type => self.class.name, :uri => @uri, :key => @key, :initial_value => @initial_value}.to_s
  end

  def hash
    {:uri => @uri, :key => @key, :type => self.class}.hash
  end

  def eql?(other)
    hash == other.hash
  end

end

class GETParamInput < Input
  def to_s
    "GET \"#{@key}\" parameter to #{@uri}"
  end
end

class FormFieldInput < Input
  attr_reader :method
  attr_reader :type
  attr_reader :on_url

  def initialize(uri, key, field_type, method)
    super(uri, key)
    @method = method
    @field_type = field_type
  end

  def to_s
    "#{@method} \"#{key}\" to #{@uri} from a #{@field_type} field."
  end
end

class CookieInput < Input
	def to_s
		"Cookie \"#{key}\""
	end
  def hash
    {:type => self.class.name, :key => @key}.hash
  end
  
  def eql?(other)
	hash == other.hash
  end
end