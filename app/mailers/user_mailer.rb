class UserMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def confirmation_instructions(user, token, opts={})
    @token = token
    mandrill_mail(
      template: 'Leo - Sign Up - Confirmation',
      subject: 'Leo - Please confirm your account with us.',
      to: user.email,
      vars: {
        'FIRST_NAME' => user.first_name,
        'LINK_CONF' => "http://localhost:8888/#/changePassword?reset_password_token=#{token}"
      }
    )
  end

  def reset_password_instructions(user, token, opts={})
    mandrill_mail(
      template: 'Leo - Password - Reset Password',
      subject: 'Leo - Instructions to reset your password',
      to: user.email,
      vars: {
        'FIRST_NAME' => user.first_name,
        'LINK' => "http://localhost:8888/#/changePassword?token=#{token}"
      }
    )
  end

  def invite_secondary_parent(enrollment, current_user)
    mandrill_mail(
      template: 'Leo - Invite User',
      subject: 'Leo Invitation',
      to: enrollment.email,
      vars: {
        'LINK' => "http://localhost:8888/#/registration?token=#{enrollment.authentication_token}",
        'SECONDARY_GUARDIAN_FIRST_NAME' => enrollment.first_name,
        'PRIMARY_GUARDIAN_FIRST_NAME' => current_user.first_name
      }
    )
  end

  def welcome_to_pratice(user)
    #this is just a placeholder, subject to change
    mandrill_mail(
        template: 'Leo - Welcome to Practice',
        subject: 'Welcome to Leo',
        to: user.email
    )
  end

  def remind_schedule_appointment(user)
    mandrill_mail(
        template: 'Leo - Remind Schedule Appointment',
        subject: "Don't forget to schedule an appointment",
        to: user.email
    )
  end

  def notify_new_message(user)
    mandrill_mail(
      template: 'Leo - Notify New Message',
      subject: 'You have a new message',
      to: user.email
    )
  end

  def password_change_confirmation(user)
    mandrill_mail(
        template: 'Leo - Password Changed',
        subject: 'Successfully changed your password!',
        to: user.email
    )
  end
end
