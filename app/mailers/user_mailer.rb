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

  def five_day_appointment_reminder(user)
    mandrill_mail(
      template: 'Leo - Five Day Appointment Reminder',
      subject: 'You have an appointment coming up soon!',
      to: user.email
    )
  end

  def same_day_appointment_reminder(user)
    mandrill_mail(
        template: 'Leo - Same Day Appointment Reminder',
        subject: 'You have an appointment today!',
        to: user.email
    )
  end

  def patient_birthday(guardian)
    mandrill_mail(
      template: 'Leo - Patient Happy Birthday',
      subject: 'Anniversary of having kids!',
      to: guardian.email
    )
  end
end
