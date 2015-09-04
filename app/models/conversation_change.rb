class ConversationChange < ActiveRecord::Base
  serialize :conversation, Hash

  belongs_to :conversation
  validates :conversation, presence: true
  after_commit :broadcast_conversation_change, on: :create

  private

  def broadcast_conversation_change
    channels = User.where.not(role_id: 4).inject([]){|channels, user| channels << 'newStatus' + user.email; channels}
    Pusher.trigger(channels, 'new_status', {new_status: status, conversation_id: id})
  end
end
