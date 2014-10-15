require_relative 'input_finder'
require 'mechanize'
require 'pp'

# An input finder that finds GET parameters on a URL
class FormParamInputFinder < InputFinder

  # Call all the input finders and aggregate the results
  # return a set of Inputs
  def discover_inputs(root)

    begin
      page = $agent.get(root)
      # root = page.canonical_uri
    rescue Mechanize::ResponseCodeError => e
      #puts e
      return Set.new
    end

    inputs = Set.new

    page.forms.each do |form|
      action_resolved = form.action.nil? ? nil : URI.join(root, form.action)
      method = form.method
      method = method.upcase.to_sym unless method.nil?


      form.fields.each do |form_field|
        inputs << HTTPParamInput.new(action_resolved, form_field.name, method)
      end
    end

    inputs.each do |input|

    end

    inputs

  end

end
