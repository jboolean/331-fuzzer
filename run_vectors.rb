class RunVectors

  def initialize(inputs)
    @inputs = inputs
  end

  def run_tests(random, vectors)
    #TODO add random testing of site
    $urls.each do |url|
      begin
        page = $agent.get(url)
      rescue Mechanize::ResponseCodeError => e
        return Set.new
      end

      forms = page.form()

      forms.each do |form|

      end
    end
  end

end