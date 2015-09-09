class ConversationChange < ActiveRecord::Base
  serialize :conversation, Hash

  belongs_to :conversation
  validates :conversation, presence: true
  after_commit :broadcast_conversation_change, on: :create

  private

  def broadcast_conversation_change
    channels = User.includes(:role).where.not(roles: {name: :guardian}).inject([]){|channels, user| channels << "newStatus#{user.email}"; channels}
    Pusher.trigger(channels, 'new_status', {new_status: conversation_change, conversation_id: id}) if channels.count > 0
  end
end
