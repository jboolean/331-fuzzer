class CustomAuthenticator

  public

  def self.authenticate(app, agent)
    case app
    when :dvwa
      self.loginDVWA(agent)
    when :bodgeit
      self.loginBodgeIt(agent)
    else
      puts "Not a valid authentication type: #{@options[:custom_auth]}"
    end
  end

  private 

  def self.loginDVWA(agent)
    page = agent.get('http://127.0.0.1/dvwa/')

    form = page.form()

    return if form.nil?
  
    form.username = 'admin'
    form.password = 'password'

    agent.submit(form, form.buttons.first)


    cookie = HTTP::Cookie.new :domain => '127.0.0.1', :name => 'security', :value => 'low', :path => '/dvwa/'
    agent.cookie_jar.delete(cookie) << cookie
  end

  def self.loginBodgeIt(agent)
    page = agent.get('http://127.0.0.1:8080/bodgeit/login.jsp')

    form = page.form()

    #Not sure what the actual name and password are, so let's hack in!
    form.username = ''
    form.password = "' or userid = 3 or 'x' = '"

    agent.submit(form, form.buttons.first)
  end
end