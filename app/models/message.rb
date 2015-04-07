# == Schema Information
#
# Table name: messages
#
#  id                   :integer          not null, primary key
#  sender_id            :integer
#  conversation_id      :integer
#  body                 :text
#  message_type         :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  escalated_to         :integer
#  resolve_requested_at :datetime
#  resolved_approved_at :datetime
#  escalated_at         :datetime
#

class Message < ActiveRecord::Base
  belongs_to :conversation
  has_many :read_receipts

  def read_by!(user)
    r = self.read_receipts.new(participant: user)
    r.save
  end

end
