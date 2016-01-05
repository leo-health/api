class EscalationNote < ActiveRecord::Base
  belongs_to :user_conversation
  belongs_to :escalated_by,  ->{where('role_id != ?', 4)}, class_name: 'User'

  validates :escalated_by, :user_conversation, :priority, presence: true

  after_commit :notify_provider, on: :create

  private

  def notify_provider
    staff = User.find(user_conversation.user_id)
    if staff.practice.try(:in_office_hour?)
      SendSmsJob.send(staff.id, 'A conversation has been escalated to you!')
    else
      if priority == 1
        NotifyEscalatedConversationJob.send(staff.id)
        SendSmsJob.send(staff.id, 'A conversation has been escalated to you!')
      end
    end
  end
end
