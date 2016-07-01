class SyncServiceMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def error(subject, message)
    mandrill_mail(
      template: 'Leo - Failed Sync Notification',
      inline_css: true,
      subject: subject,
      to: [ "sync@leohealth.com" ],
      vars: {
          'BODY': message,
          'RAILS_ENV': ENV['RAILS_ENV']
        }
      )
  end
end
