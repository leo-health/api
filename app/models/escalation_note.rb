class EscalationNote < ActiveRecord::Base
  belongs_to :user_conversation
  belongs_to :escalated_by,  ->{where('role_id != ?', 4)}, class_name: 'User'

  validates :escalated_by, :user_conversation, :priority, presence: true

  after_commit :notify_provider, on: :create

  private

  def notify_provider
    staff = User.find(user_conversation.user_id)
    if staff.practice.try(:in_office_hour?)
      SendSmsJob.new(staff.id, 'A conversation has been escalated to you!').send
    else
      if priority == 1
        UserMailer.delay.notify_escalated_conversation(staff)
        SendSmsJob.new(staff.id, 'A conversation has been escalated to you!').send
      end
    end
  end
end
