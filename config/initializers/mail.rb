MandrillMailer.configure do |config|
  config.api_key = ENV["MANDRILL_API_KEY"]
  config.deliver_later_queue_name = :default

  unless Rails.env.production?
    config.interceptor = Proc.new {|params|
      params['to'].each do |receiver|
        params['subject'] += "From: #{params['from_email']} in #{Rails.env} environment"
        unless receiver['email'].split("@").last.downcase == "leohealth.com"
          receiver['email'] = "mailer@leohealth.com"
        end
      end
    }
  end
end
