class EscalationNote < ActiveRecord::Base
  belongs_to :escalated_to, ->{where('role_id != ?', 4)}, class_name: 'User'
  belongs_to :escalated_by, ->{where('role_id != ?', 4)}, class_name: 'User'

  validates :escalated_by, :escalated_to, :priority, presence: true

  after_commit :notify_escalatee, on: :create

  private

  def notify_escalatee
    escalatee = escalated_to
    if escalatee.practice.try(:in_office_hour?)
      SendSmsJob.send(escalatee.id, 'A conversation has been escalated to you!')
    else
      if priority == 1
        NotifyEscalatedConversationJob.send(escalatee.id)
        SendSmsJob.send(escalatee.id, 'A conversation has been escalated to you!')
      end
    end
  end
end
