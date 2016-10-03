require "rails_helper"
describe "SendBlastMessageFromLeoBot" do
  before do
    10.times{create(:family_with_members)}
    create(:user, :bot)
    User.guardians.all.each{|g| g.sessions.create(device_type: "iphone", device_token: SecureRandom.urlsafe_base64(nil, false))}
  end

  describe ".send_and_notify_message_to_families" do
    it "creates and notifies a message for each guardian" do
      n_notifications = User.guardians.count
      n_messages = Family.count
      expect(Pusher).to receive(:trigger).exactly(n_notifications).times
      expect{
        SendBlastMessageFromLeoBot.new.send_and_notify_message_to_families(families: Family.all, body: "test message")
      }.to change{
        Message.count
      }.by(n_messages)
      expect(Delayed::Job.where(queue: "apns_notification").count).to eq(n_notifications)
    end
  end
end
