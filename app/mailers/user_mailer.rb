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
        'LINK': "#{ENV['API_HOST']}/deep_link/confirm_email"
      }
    )
  end

  def reset_password_instructions(user, token, opts={})
    mandrill_mail(
      template: 'Leo - Password - Reset Password',
      subject: 'Leo - Instructions to reset your password',
      to: user.email,
      vars: {
        'FIRST_NAME': user.first_name,
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/#/changePassword?token=#{token}"
      }
    )
  end

  def invite_secondary_parent(enrollment, current_user)
    mandrill_mail(
      template: 'Leo - Invite User',
      subject: 'Leo Invitation',
      to: enrollment.email,
      vars: {
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/#/registration?token=#{enrollment.authentication_token}",
        'SECONDARY_GUARDIAN_FIRST_NAME': enrollment.first_name,
        'PRIMARY_GUARDIAN_FIRST_NAME': current_user.first_name
      }
    )
  end

  def five_day_appointment_reminder(user, appointment)
    patient = appointment.patient
    start_datetime = appointment.start_datetime
    day_of_week = start_datetime.strftime("%A")
    appointment_time = start_datetime.in_time_zone.strftime("%I:%M %p")

    mandrill_mail(
      template: 'Leo - Five Day Appointment Reminder',
      subject: 'You have an appointment coming up soon!',
      to: user.email,
      vars: {
        'PRIMARY_GUARDIAN_FIRST_NAME': user.first_name,
        'CHILD_FIRST_NAME': patient.first_name,
        'APPOINTMENT_DAY_OF_WEEK': day_of_week,
        'APPOINTMENT_TIME': appointment_time,
        'LINK': "#{ENV['API_HOST']}/api/v1/deep_link?type=appointment&type_id=#{appointment.id}"
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

  def same_day_appointment_reminder(user, appointment)
    appointment_time = appointment.start_datetime.in_time_zone.strftime("%I:%M %p")
    mandrill_mail(
        template: 'Leo - Same Day Appointment Reminder',
        subject: 'You have an appointment today!',
        to: user.email,
        vars: {
          'PRIMARY_GUARDIAN_FIRST_NAME': user.first_name,
          'CHILD_FIRST_NAME': appointment.patient.first_name,
          'APPOINTMENT_TIME': appointment_time,
          'LINK': "#{ENV['API_HOST']}/api/v1/deep_link?type=appointment&type_id=#{appointment.id}"
        }
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
      to: user.email,
      vars: {
        'FIRST_NAME': user.first_name,
        'LINK': "#{ENV['API_HOST']}/api/v1/deep_link?type=conversation&type_id=#{conversation.id}"
      }
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
        'COUNT': count
      }
    )
  end

  def remind_unread_messages(user, staff_message)
    mandrill_mail(
      template: 'Leo - Message Not Read Over an Hour',
      subject: "You have unread message from last hour!",
      to: user.email,
      vars: {
        'BODY': staff_message.body,
        'STAFF': staff_message.sender.full_name,
        'GUARDIAN_FIRST_NAME': user.first_name
      }
    )
  end

  def primary_guardian_approve_invitation(primary_guardian, enrollment_auth_token)
    mandrill_mail(
      template: 'Leo - Approve Invitation',
      subject: "You have a pending invitation needs action!",
      to: primary_guardian.email,
      vars: {
        'PRIMARY_GUARDIAN_FIRST_NAME': primary_guardian.first_name,
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/#/acceptInvitation?token=#{enrollment_auth_token}"
      }
    )
  end
end
