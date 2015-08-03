class UserMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def confirmation_instructions(user, token, opts={})
    @token = token
    mandrill_mail(
      template: 'Leo email confirmation',
      subject: 'Leo email confirmation',
      to: user.email,
      vars: {
        'FIRST_NAME' => user.first_name,
        'LINK' => "http://localhost:8888/#/changePassword?reset_password_token=#{token}"
      }
    )
  end

  def reset_password_instructions(user, token, opts={})
    mandrill_mail(
      template: 'Leo - Reset Password',
      subject: 'Reset password instructions',
      to: user.email,
      vars: {
        'LINK' => "http://localhost:8888/#/changePassword?token=#{token}",
        'FIRST_NAME' => user.first_name
      }
    )
  end
end
