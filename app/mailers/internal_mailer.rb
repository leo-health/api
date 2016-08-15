class InternalMailer < MandrillMailer::MessageMailer
  default from: 'info@leohealth.com'

  def sync_service_error(subject, message)
    mandrill_mail(
      inline_css: true,
      subject: subject + " " + ENV['RAILS_ENV'],
      to: [ "sync@leohealth.com" ],
      text: message
      )
  end
end
