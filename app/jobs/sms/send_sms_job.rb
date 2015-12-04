class SendSmsJob < Struct.new(:receiver_id, :body)
  def perform
    receiver = User.find_by_id(receiver_id)
  end

  def send
    Delayed::Job.enqueue self
  end

  private

  def sms_cs_user
    TWILIO.account.messages.create(from: TWILIO_PHONE_NUMBER, to: receiver.phone, body: body)
  end
end

# class InviteParentJob < Struct.new(:enrollment_id, :user_id)
#   def perform
#     enrollment = Enrollment.find_by_id(enrollment_id)
#     current_user = User.find_by_id(user_id)
#     UserMailer.invite_secondary_parent(enrollment, current_user).deliver if ( enrollment && current_user )
#   end
#
#   def send
#     Delayed::Job.enqueue self
#   end
# end
