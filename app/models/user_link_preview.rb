class UserLinkPreview < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :link_preview, polymorphic: true
  belongs_to :user
  belongs_to :owner, polymorphic: true

  after_commit :actions_after_content_shared, after: :commit

  validates :link_preview, presence: true

  def self.published
    # TODO: when updating to Rails 5, use .or as a scope
    # https://github.com/rails/rails/commit/9e42cf019f2417473e7dcbfcb885709fa2709f89
    deep_link_notifications = where(dismissed_at: nil)
    deep_link_notifications += where.not(dismissed_at: nil).where("dismissed_at >= ?", Time.now)
  end

  def published?
    return true unless dismissed_at
    dismissed_at > Time.now
  end

  def actions_after_content_shared
    return nil unless sends_push_notification_on_publish
    
    if link_preview.try(:notification_message)

      on_create = self.previous_changes.key?(:id)
      if on_create && published?
        return send_new_content_notification
      end

      return nil unless old_val = self.previous_changes[:dismissed_at].try(:first)
      previously_unpublished = old_val && old_val < Time.now
      if published? && previously_unpublished
        send_new_content_notification
      end
    end
  end

  def send_new_content_notification
    user.collect_device_tokens.map do |device_token|
      NewContentApnsJob.send(device_token, link_preview.id)
    end
  end
end
