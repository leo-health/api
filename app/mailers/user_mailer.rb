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

  def reset_password(user, token)
    mandrill_mail(
      template: 'reset_password',
      subject: 'reset_password',
      to: user.email,
      vars: {
        'EMAIL' => user.email,
        'LINK' => "http://localhost:8888/#/changePassword?reset_password_token=#{token}"
      }
    )
  end
end
