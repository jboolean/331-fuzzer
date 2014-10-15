class RunVectors

  def initialize(inputs)
    @inputs = inputs
  end

  def run_tests(random, vectors)

    @inputs.each do |input|

    end

    $urls.each do |url|
      begin
        page = $agent.get(url)
      rescue Mechanize::ResponseCodeError => e
        return Set.new
      end

      forms = page.forms

      forms.each do |form|
        vectors.each do |vector|
          form.fields.each do |field|
            field.value = vector
          end

          page = form.submit

          if page.contents.to_s.include? '<' || page.contents.to_s.include? '>'
            $possibleVulnerabilities << ('Vulnerability found at ' + page.name + ' in field' + form.field.name)
          end
        end
      end
    end
  end
end