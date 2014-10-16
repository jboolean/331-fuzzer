#intended to be subclassed by specific kinds of inputs
class Input
  include Comparable
  attr_reader :uri
  attr_reader :key

  def initialize(uri, key)
    unless uri.is_a? String
      uri = uri.to_s
    end
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

  # Override me!
  def inject(agent, value)
    throw "This input is not usable for testing."
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
    "#{@verb.to_s.upcase} \"#{key}\" on #{@uri}"
  end

  def hash
    {:uri => @uri, :key => @key, :type => self.class, :verb => @verb}.hash
  end

  def inject(agent, value) 
    case @verb
    when :get
      agent.get(@uri, {@key.to_sym => value})
    when :post
      agent.post(@uri, {@key.to_sym => value})
    when :put
      agent.put(@uri, value)
    else
      agent.request_with_entity(@verb, @uri, value)
    end
  end
end

class CookieInput < Input
  def initialize(uri, key, cookie)
    super(uri, key)
    @original_cookie = cookie
  end

	def to_s
		"Cookie \"#{key}\""
	end
  def hash
    {:type => self.class.name, :key => @key}.hash
  end
  
  def eql?(other)
    hash == other.hash
  end

  def inject(agent, value)
    cookie = HTTP::Cookie.new :domain => @original_cookie.domain, :name => @key, :value => value, :path => @original_cookie.path

    # deletes any matching cookies
    agent.cookie_jar.delete(@original_cookie) << cookie
    agent.get(@uri)

    #put things back as they were
    agent.cookie_jar.delete(cookie) << @original_cookie
  end
end