class UserLinkPreview < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :link_preview, polymorphic: true
  belongs_to :user
  belongs_to :owner, polymorphic: true

  after_commit :actions_after_content_shared, on: :create

  validates :link_preview, presence: true

  def actions_after_content_shared
    send_new_content_notification if link_preview.try(:category).try(:to_sym) == :milestone_content
  end

  def send_new_content_notification
    user.collect_device_tokens.each do |device_token|
      NewContentApnsJob.send(device_token, link_preview.id)
    end
  end
end
