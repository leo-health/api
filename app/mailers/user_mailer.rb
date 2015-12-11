class UserMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def confirmation_instructions(user, token, opts={})
    @token = token
    mandrill_mail(
      template: 'Leo - Sign Up - Confirmation',
      subject: 'Leo - Please confirm your account with us.',
      to: user.email,
      vars: {
        'FIRST_NAME': user.first_name,
        'LINK_CONF': "http://localhost:8888/#/changePassword?reset_password_token=#{token}"
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

  def welcome_to_pratice(user)
    #this is just a placeholder, subject to change
    mandrill_mail(
      template: 'Leo - Welcome to Practice',
      subject: 'Welcome to Leo',
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

  def remind_schedule_appointment(user)
    mandrill_mail(
      template: 'Leo - Remind Schedule Appointment',
      subject: "Don't forget to schedule an appointment",
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

  def notify_new_message(user)
    mandrill_mail(
      template: 'Leo - Notify New Message',
      subject: 'You have a new message',
      to: user.email
    )
  end

  def account_confirmation_reminder(user)
    mandrill_mail(
      template: 'Leo - Account Confirmation Reminder',
      subject: 'One day left to confirm your account with Leo',
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


  def notify_escalated_conversation(user)
    mandrill_mail(
      template: 'Leo - Escalated Conversation',
      subject: 'A conversation has been escalated to you with high priority!',
      to: user.email
    )
  end

  def unaddressed_conversations_digest(user, count, state)
    mandrill_mail(
      template: 'Leo - Unaddressed Conversations Digest',
      subject: "You have some work to do now, address your #{state} conversations",
      to: user.email,
      vars: {
        'COUNT': count,
      }
    )
  end
end
