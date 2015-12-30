MandrillMailer.configure do |config|
  #TODO save api key to server
  if Rails.env.test?
    config.api_key = 'r0D8STwnRJmJ9LiHrazMlw'
  else
    config.api_key = 'Ubx9Pj2zlIT48WmtwxX-5Q'
  end

  if %w(test, development).any?{|e|e == Rails.env}
    config.interceptor = Proc.new {|params|
      params[:to] =  [
          params[:to],
          { email: "mailer@leohealth.com", name: "Wuang"}
      ].flatten
    }
  end
end
