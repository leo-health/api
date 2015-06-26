module Leo::V1::SuccessFormatter
  def self.call object, env
    { :status => 'ok', :data => object }.to_json
  end
end
