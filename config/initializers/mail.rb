MandrillMailer.configure do |config|
  config.api_key = ENV["MANDRILL_API_KEY"]
  config.deliver_later_queue_name = :default

  if %w(test development develop).any?{|e|e == Rails.env}
    config.interceptor = Proc.new {|params|
      params['to'].each do |receiver|
        unless receiver['email'].split("@").last.downcase == "leohealth.com"
          receiver['email'] = "mailer@leohealth.com"
        end
      end
    }
  end
end
