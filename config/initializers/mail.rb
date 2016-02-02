MandrillMailer.configure do |config|
  config.api_key = ENV["MANDRILL_API_KEY"]
  config.deliver_later_queue_name = :default

  if %w(test, development).any?{|e|e == Rails.env}
    config.interceptor = Proc.new {|params|
      params[:to] =  [
        params[:to],
        { email: "mailer@leohealth.com", name: "Wuang"}
      ].flatten
    }
  end
end
