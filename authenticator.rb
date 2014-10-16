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
  end

  def self.loginBodgeIt(agent)
    page = agent.get('http://127.0.0.1:8080/bodgeit/login.jsp')

    form = page.form()

    #Not sure what the actual name and password are.
    form.username = 'admin'
    form.password = 'password'

    agent.submit(form, form.buttons.first)
  end
end