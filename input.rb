#intended to be subclassed by specific kinds of inputs
class Input
  include Comparable
  attr_reader :uri
  attr_reader :key

  def initialize(uri, key)
    @uri = uri
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

  def <=>(other)
    urlComp = uri.to_s <=> other.uri.to_s
    return urlComp unless urlComp == 0
    classComp = self.class.name <=> other.class.name
    return classComp unless classComp == 0
    return key <=> other.key      
  end

end

class HTTPParamInput < Input
  attr_reader :verb

  def initialize(uri, key, method)

    #remove params and hash from uri
    noParamUri = uri.to_s.sub(/[\?#].*$/, '')

    super(noParamUri, key)
    @verb = method
  end

  def to_s
    "#{@verb} \"#{key}\" to #{@uri}"
  end

  def hash
    {:uri => @uri, :key => @key, :type => self.class, :verb => @verb}.hash
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