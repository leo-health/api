class SyncServiceMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def error(subject, message)
    mandrill_mail(
      template: 'Leo - Failed Sync Notification',
      subject: subject,
      to: SyncService.configuration.admin_emails,
      vars: { 'BODY': message }
      )
  end
end
