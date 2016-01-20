class EscalationNote < ActiveRecord::Base
  belongs_to :escalated_to, ->{where('role_id != ?', 4)}, class_name: 'User'
  belongs_to :escalated_by, ->{where('role_id != ?', 4)}, class_name: 'User'
  belongs_to :conversation

  validates :conversation, :escalated_by, :escalated_to, :priority, presence: true

  after_commit :notify_escalatee, on: :create

  private

  def notify_escalatee
    NotifyEscalatedConversationJob.send(escalatee.id) if send_email?
    SendSmsJob.send(escalated_to.id, escalated_by.id, :escalation, Time.now.to_s) if send_sms?
  end

  def send_sms?
    priority == 1 || escalatee.practice.try(:in_office_hour?)
  end

  def send_email?
    priority == 1 && !escalatee.practice.try(:in_office_hour?)
  end
end
