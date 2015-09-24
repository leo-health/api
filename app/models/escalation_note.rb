class EscalationNote < ActiveRecord::Base
  belongs_to :message
  belongs_to :assignor,  ->{where.not roles: {name: :guardian}}, class_name: 'User'
  belongs_to :assignee,  ->{where.not roles: {name: :guardian}}, class_name: 'User'

  validates :assignor, :assignee, :message, :priority_level, presence: true
  validate :staff_identity

  def staff_identity
    if assignee.has_role? :guardian
      errors.add(:assignee_id, "must be a staff")
    elsif assignor.has_role? :guardian
      errors.add(:assignor_id, "must be a staff")
    end
  end
end
