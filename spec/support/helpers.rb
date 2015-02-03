module SpecHelpers
  def responds_with_status(status)
    expect(last_response.status).to eq(status)
  end
  def responds_with_json
    expect(last_response.original_headers["Content-Type"]).to eq('application/json')
  end
  def json_body
    JSON.parse(last_response.body)
  end
  def responds_with_identical_to(model_instance)
    comparison_results = json_body.keys.map do |k|
      json_body[k] == model_instance.send(k.to_sym).to_s
    end
    expect(comparison_results).to_not include(false)
  end
end
