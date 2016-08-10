class UserMailer < MandrillMailer::TemplateMailer
  default from: 'info@leohealth.com'

  def invite_all_exempt_synced_users
    onboarding_group = OnboardingGroup.generated_from_athena
    onboarding_group.users.find_each do |guardian|
      invite_exempt_synced_user(guardian)
    end
  end

  def reinvite_all_exempt_synced_users
    OnboardingGroup.generated_from_athena.users.incomplete.find_each do |guardian|
      reinvite_exempt_synced_user(guardian)
    end
  end

  def invite_exempt_synced_user(user)
    mandrill_mail(
      template: 'Leo - Exempt User Registration',
      inline_css: true,
      subject: 'Leo + Flatiron Pediatrics - Get the app.',
      to: user.unconfirmed_email || user.email,
      vars: {
        'LINK': user.invitation_url
      }
    ).delay(queue: 'exempt_registration_email', owner: user).deliver
  end

  def reinvite_exempt_synced_user(user)
    mandrill_mail(
      template: 'Leo - Exempt User Registration Reminder',
      inline_css: true,
      subject: 'Leo + Flatiron Pediatrics Membership for Free - Register Now',
      to: user.unconfirmed_email || user.email,
      vars: {
        'LINK': user.invitation_url
      }
    ).delay(queue: 'exempt_registration_email', owner: user).deliver
   end

  def confirmation_instructions(user, token, opts={})
    mandrill_mail(
      template: 'Leo - Sign Up Confirmation',
      inline_css: true,
      subject: 'Leo - Please confirm your account!',
      to: user.unconfirmed_email || user.email,
      vars: {
        'GUARDIAN_FIRST_NAME': user.first_name.capitalize,
        'LINK': "#{ENV['API_HOST']}/api/v1/confirm_email?token=#{token}"
      }
    )
  end

  def reset_password_instructions(user, token, opts={})
    mandrill_mail(
      template: 'Leo - Password Reset',
      inline_css: true,
      subject: 'Leo - Password reset request.',
      to: user.unconfirmed_email || user.email,
      vars: {
        'FIRST_NAME': user.first_name.capitalize,
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/changePassword?token=#{token}"
      }
    )
  end

  def invite_secondary_parent(secondary_user, current_user)
    mandrill_mail(
      template: 'Leo - Invite a Secondary Guardian',
      inline_css: true,
      subject: "You've been invited to join Leo + Flatiron Pediatrics!",
      to: secondary_user.email,
      vars: {
        'LINK': secondary_user.invitation_url,
        'SECONDARY_GUARDIAN_FIRST_NAME': secondary_user.first_name.capitalize,
        'PRIMARY_GUARDIAN_FIRST_NAME': current_user.first_name.capitalize
      }
    )
  end

  def welcome_to_pratice(user)
    mandrill_mail(
      template: 'Leo - Welcome to Practice',
      inline_css: true,
      subject: 'Welcome to Leo + Flatiron Pediatrics!',
      to: user.email,
      vars: {
        'GUARDIAN_FIRST_NAME': user.first_name.capitalize
      }
    )
  end

  def complete_user_two_day_appointment_reminder(user, appointment)
    appointment_time = appointment.start_datetime.in_time_zone.strftime("%I:%M %p")
    appointment_day = appointment.start_datetime.in_time_zone.strftime("%A")
    mandrill_mail(
        template: 'Leo - 48 Hour Appt Reminder - Registered',
        inline_css: true,
        subject: 'Leo - Appointment Reminder, see you soon!',
        from: 'info@leohealth.com',
        to: user.email,
        vars: {
          'CHILD_FIRST_NAME': appointment.patient.first_name.capitalize,
          'APPOINTMENT_TIME': appointment_time,
          'APPOINTMENT_DAY_OF_WEEK': appointment_day
        }
    )
  end

  def incomplete_user_two_day_appointment_reminder(user, appointment)
    appointment_time = appointment.start_datetime.in_time_zone.strftime("%I:%M %p")
    appointment_day = appointment.start_datetime.in_time_zone.strftime("%A")
    mandrill_mail(
        template: 'Leo - 48 Hour Appt Reminder - NOT registered',
        inline_css: true,
        subject: 'Leo - Appointment Reminder, see you soon!',
        from: 'info@leohealth.com',
        to: user.email,
        vars: {
          'CHILD_FIRST_NAME': appointment.patient.first_name.capitalize,
          'APPOINTMENT_TIME': appointment_time,
          'APPOINTMENT_DAY_OF_WEEK': appointment_day
        }
    )
  end

  def patient_birthday(guardian, patient)
    mandrill_mail(
      template: 'Leo - Patient Birthday',
      inline_css: true,
      subject: 'Happy Birthday!',
      to: guardian.email,
      vars: {
        'PATIENT_FIRST_NAME': patient.first_name.capitalize
      }
    )
  end

  def account_confirmation_reminder(user)
    mandrill_mail(
      template: 'Leo - Account Confirmation Reminder',
      inline_css: true,
      subject: 'Important - Please confirm your account with Leo!',
      to: user.email,
      vars: {
        'FIRST_NAME': user.first_name.capitalize,
        'LINK': "#{ENV['API_HOST']}/api/v1/confirm_email?token=#{user.confirmation_token}"
      }
    )
  end

  def password_change_confirmation(user)
    mandrill_mail(
      template: 'Leo - Password Changed Confirmation',
      inline_css: true,
      subject: 'Leo - Your password has been successfully changed!',
      to: user.email,
      vars: {
        'FIRST_NAME': user.first_name.capitalize
      }
    )
  end


  def notify_escalated_conversation(user)
    mandrill_mail(
      template: 'Leo Provider - Case Assigned',
      inline_css: true,
      subject: 'A conversation has been assigned to you!',
      to: user.email,
      vars: {
        'STAFF_FIRST_NAME': user.first_name.capitalize,
        'LINK': "#{ENV['PROVIDER_APP_HOST']}"
      }
    )
  end

  def unaddressed_conversations_digest(user, count)
    mandrill_mail(
      template: 'Leo Provider - Unresolved Assigned Cases',
      inline_css: true,
      subject: "You have unresolved cases that have been assigned to you.",
      to: user.email,
      vars: {
        'STAFF_FIRST_NAME': user.first_name.capitalize,
        'COUNT': count
      }
    )
  end

  def remind_unread_messages(user, staff_message)
    conversation_id = user.family.conversation.id if user.family

    mandrill_mail(
      template: 'Leo - Unread Message',
      inline_css: true,
      subject: "You have unread messages!",
      to: user.email,
      vars: {
        'LINK': "#{ENV['API_HOST']}/api/v1/deep_link?type=conversation&type_id=#{conversation_id}",
        'STAFF_FULL_NAME': staff_message.sender.full_name,
        'GUARDIAN_FIRST_NAME': user.first_name.capitalize
      }
    )
  end

  def primary_guardian_approve_invitation(primary_guardian, invited_guardian)
    mandrill_mail(
      template: 'Leo - Secondary Guardian Confirmation',
      inline_css: true,
      subject: "Leo - Please confirm #{invited_guardian.first_name.capitalize}'s account!",
      to: primary_guardian.email,
      vars: {
        'PRIMARY_GUARDIAN_FIRST_NAME': primary_guardian.first_name.capitalize,
        'SECONDARY_GUARDIAN_FULL_NAME': invited_guardian.full_name,
        'SECONDARY_GUARDIAN_FIRST_NAME': invited_guardian.first_name.capitalize,
        'SECONDARY_GUARDIAN_EMAIL': invited_guardian.email,
        'LINK': "#{ENV['PROVIDER_APP_HOST']}/registration/acceptInvitation?token=#{invited_guardian.invitation_token}"
      }
    )
  end
end
