require "rails_helper"
describe "SendBlastMessageFromLeoBot" do
  before do
    10.times{create(:family_with_members)}
    create(:user, :bot)
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
    end
  end
end
