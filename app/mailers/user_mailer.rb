class UserMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def invite_all_exempt_synced_users
    onboarding_group = OnboardingGroup.generated_from_athena

    # byebug


    onboarding_group.users.find_each do |guardian|
      invite_exempt_synced_user(guardian)
    end
  end

  def invite_exempt_synced_user(user)
    session = user.sessions.first || user.create_onboarding_session
    token = session.authentication_token
    delay(queue: 'exempt_registration_email', owner: user).mandrill_mail(
      template: 'Leo - Exempt User Registration',
      subject: '',
      to: user.unconfirmed_email || user.email,
      vars: {
        'FIRST_NAME': user.first_name,
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/registration/invited?onboarding_group=primary&token=#{token}",
      }
    )
  end

  def confirmation_instructions(user, token, opts={})
    mandrill_mail(
      template: 'Leo - Sign Up Confirmation',
      subject: 'Leo - Please confirm your account!',
      to: user.unconfirmed_email || user.email,
      vars: {
        'GUARDIAN_FIRST_NAME': user.first_name,
        'LINK': "#{ENV['API_HOST']}/api/v1/users/confirm_email?token=#{token}"
      }
    )
  end

  def reset_password_instructions(user, token, opts={})
    mandrill_mail(
      template: 'Leo - Password Reset',
      subject: 'Leo - Password reset request.',
      to: user.unconfirmed_email || user.email,
      vars: {
        'FIRST_NAME': user.first_name,
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/changePassword?token=#{token}"
      }
    )
  end

  def invite_secondary_parent(enrollment, current_user)
    mandrill_mail(
      template: 'Leo - Invite a Secondary Guardian',
      subject: "You've been invited to join Leo + Flatiron Pediatrics!",
      to: enrollment.email,
      vars: {
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/registration/invited?onboarding_group=secondary&token=#{enrollment.invitation_token}",
        'SECONDARY_GUARDIAN_FIRST_NAME': enrollment.first_name,
        'PRIMARY_GUARDIAN_FIRST_NAME': current_user.first_name
      }
    )
  end

  def five_day_appointment_reminder(user, appointment)
    patient = appointment.patient
    if appointment.start_datetime
      day_of_week = appointment.start_datetime.strftime("%A")
      appointment_time = appointment.start_datetime.in_time_zone.strftime("%I:%M %p")
    end

    mandrill_mail(
      template: 'Leo - Five Day Appointment Reminder',
      subject: 'Leo - Friendly reminder, you have an upcoming appointment!',
      to: user.email,
      from: "info@leohealth.com",
      vars: {
        'GUARDIAN_FIRST_NAME': user.first_name,
        'CHILD_FIRST_NAME': patient.first_name,
        'APPOINTMENT_DAY_OF_WEEK': day_of_week,
        'APPOINTMENT_TIME': appointment_time,
        'LINK': "#{ENV['API_HOST']}/api/v1/deep_link?type=appointment&type_id=#{appointment.id}"
      }
    )
  end

  def welcome_to_pratice(user)
    mandrill_mail(
      template: 'Leo - Welcome to Practice',
      subject: 'Welcome to Leo + Flatiron Pediatrics!',
      to: user.email,
      vars: {
        'GUARDIAN_FIRST_NAME': user.first_name
      }
    )
  end

  def same_day_appointment_reminder(user, appointment)
    appointment_time = appointment.start_datetime.in_time_zone.strftime("%I:%M %p")
    mandrill_mail(
        template: 'Leo - Same Day Appointment Reminder',
        subject: 'Leo - Appointment Reminder, see you soon!',
        from: 'info@leohealth.com',
        to: user.email,
        vars: {
          'PRIMARY_GUARDIAN_FIRST_NAME': user.first_name,
          'CHILD_FIRST_NAME': appointment.patient.first_name,
          'APPOINTMENT_TIME': appointment_time,
          'LINK': "#{ENV['API_HOST']}/api/v1/deep_link?type=appointment&type_id=#{appointment.id}"
        }
    )
  end

  def patient_birthday(guardian, patient)
    mandrill_mail(
      template: 'Leo - Patient Birthday',
      subject: 'Happy Birthday!',
      to: guardian.email,
      vars: {
        'PATIENT_FIRST_NAME': patient.first_name
      }
    )
  end

  def account_confirmation_reminder(user)
    mandrill_mail(
      template: 'Leo - Account Confirmation Reminder',
      subject: 'Important - Please confirm your account with Leo!',
      to: user.email,
      vars: {
        'FIRST_NAME': user.first_name,
        'LINK': "#{ENV['API_HOST']}/api/v1/users/confirm_email?token=#{user.confirmation_token}"
      }
    )
  end

  def password_change_confirmation(user)
    mandrill_mail(
      template: 'Leo - Password Changed Confirmation',
      subject: 'Leo - Your password has been successfully changed!',
      to: user.email,
      vars: {
        'FIRST_NAME': user.first_name
      }
    )
  end


  def notify_escalated_conversation(user)
    mandrill_mail(
      template: 'Leo Provider - Case Assigned',
      subject: 'A conversation has been assigned to you!',
      to: user.email,
      vars: {
        'STAFF_FIRST_NAME': user.first_name,
        'LINK': "#{ENV['PROVIDER_APP_HOST']}"
      }
    )
  end

  def unaddressed_conversations_digest(user, count)
    mandrill_mail(
      template: 'Leo Provider - Unresolved Assigned Cases',
      subject: "You have unresolved cases that have been assigned to you.",
      to: user.email,
      vars: {
        'STAFF_FIRST_NAME': user.first_name,
        'COUNT': count
      }
    )
  end

  def remind_unread_messages(user, staff_message)
    conversation_id = user.family.conversation.id if user.family

    mandrill_mail(
      template: 'Leo - Unread Message',
      subject: "You have unread messages!",
      to: user.email,
      vars: {
        'LINK': "#{ENV['API_HOST']}/api/v1/deep_link?type=conversation&type_id=#{conversation_id}",
        'STAFF_FULL_NAME': staff_message.sender.full_name,
        'GUARDIAN_FIRST_NAME': user.first_name
      }
    )
  end

  def primary_guardian_approve_invitation(primary_guardian, enrollment)
    mandrill_mail(
      template: 'Leo - Secondary Guardian Confirmation',
      subject: "Leo - Please confirm #{enrollment.first_name}'s account!",
      to: primary_guardian.email,
      vars: {
        'PRIMARY_GUARDIAN_FIRST_NAME': primary_guardian.first_name,
        'SECONDARY_GUARDIAN_FULL_NAME': "#{enrollment.first_name} #{enrollment.last_name}",
        'SECONDARY_GUARDIAN_FIRST_NAME': "#{enrollment.first_name}",
        'SECONDARY_GUARDIAN_EMAIL': "#{enrollment.email}",
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/registration/acceptInvitation?token=#{enrollment.invitation_token}"
      }
    )
  end
end
