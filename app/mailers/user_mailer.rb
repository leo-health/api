class UserMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def confirmation_instructions(user, token, opts={})
    @token = token
    mandrill_mail(
      template: 'confirm_email',
      subject: 'Please confirm your account',
      to: user.email,
      vars: {
        'EMAIL' => user.email,
        'LINK' => "http://localhost:8888/#/changePassword?reset_password_token=#{token}"
      }
    )
  end

  def reset_password_instructions(user, token, opts={})
    mandrill_mail(
      template: 'reset_password',
      subject: 'reset_password',
      to: user.email,
      vars: {
        'EMAIL' => user.email,
        'LINK' => "http://localhost:8888/#/changePassword?reset_password_token=#{token}",
        'FIRST_Name' => user.first_name
      }
    )
  end
end
