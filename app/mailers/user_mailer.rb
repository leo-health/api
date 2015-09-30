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
        'LINK_CONF' => "http://localhost:8888/#/changePassword?reset_password_token=#{token}"
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

  def invite_secondary_parent(enrollment)
    mandrill_mail(
      template: 'Leo - Invite User',
      subject: 'Leo Invitation',
      to: enrollment.email,
      vars: {
        'LINK' => "http://localhost:8888/#/inviteParent?authentication_token=#{enrollment.authentication_token}",
        'FIRST_NAME' => enrollment.first_name
      }
    )
  end
end
