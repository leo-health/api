MandrillMailer.configure do |config|
  #TODO save api key to server
  config.api_key = 'Ubx9Pj2zlIT48WmtwxX-5Q'

  if %w(test, development).any?{|e|e == Rails.env}
    config.interceptor = Proc.new {|params|
      params[:to] =  [
          params[:to],
          { email: "wuang@leohealth.com", name: "Wuang"}
      ].flatten
    }
  end
end
