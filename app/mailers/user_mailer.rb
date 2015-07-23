class UserMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def trial(user)
    mandrill_mail(
      template: 'trial',
      subject: 'trial',
      to: user.email,
      vars: {
          'EMAIL' => user.email
      }
    )
  end
end
