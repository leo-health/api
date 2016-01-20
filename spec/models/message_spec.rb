require 'rails_helper'

RSpec.describe Message, type: :model do
  let!(:bot){ create(:user, :bot) }
  let!(:customer_service){ create(:user, :customer_service)}

  describe "relations" do
    it{ is_expected.to belong_to(:conversation) }
    it{ is_expected.to belong_to(:sender).class_name('User') }

    it{ is_expected.to have_one(:message_photo) }

    it{ is_expected.to have_many(:read_receipts) }
    it{ is_expected.to have_many(:readers).class_name('User').through(:read_receipts) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:conversation) }
    it { is_expected.to validate_presence_of(:sender) }
    it { is_expected.to validate_presence_of(:type_name) }

    context "if text message" do
      before { allow(subject).to receive(:text_message?).and_return(true) }
      it { is_expected.to validate_presence_of(:body) }
    end

    context "if not text message" do
      before { allow(subject).to receive(:text_message?).and_return(false) }
      it { is_expected.not_to validate_presence_of(:body) }
    end
  end

  describe "callbacks" do
    describe "after commit on create" do
      let!(:guardian){ create(:user) }
      let(:session){ guardian.sessions.create(device_token: "token") }
      let!(:conversation){ guardian.family.conversation }

      before do
        $redis.set("#{customer_service.id}online?", "no")
      end

      def create_message
        conversation.messages.create( body: "Hello", sender: guardian, type_name: "text")
      end

      context "on guardian received new messages" do
        before do
          $redis.set("#{customer_service.id}online?", "yes")
        end

        def create_message
          conversation.messages.create( body: "Hello", sender: customer_service, type_name: "text")
        end

        it "should send email notifications" do
          expect{ create_message }.to change(Delayed::Job, :count).by(1)
        end
      end

      context "on update conversation information" do
        it "should set or update last_message_created field on conversation" do
          message = create_message
          expect( conversation.reload.last_message_created_at.to_s ).to eq(message.created_at.to_s)
        end
      end

      context "customer user is offline, and not in cooldown period" do
        before do
          Timecop.freeze
          $redis.set("#{customer_service.id}next_messageAt", Time.now - 1.minute)
        end

        after do
          Timecop.return
        end

        def create_message
          conversation.messages.create( body: "Hello", sender: guardian, type_name: "text")
        end

        it "should sms customer service user about the newly created message" do
          expect{ create_message }.to change(Delayed::Job, :count).by(1)
        end
      end

      context "customer user is offline, and in cooldown period" do
        before do
          Timecop.freeze
          $redis.set("#{customer_service.id}next_messageAt", Time.now + 1.minute)
        end

        after do
          Timecop.return
        end

        it "should not sms customer service user, but create a delayed job to run after cool down period" do
          expect{ create_message }.to change(Delayed::Job, :count).by(1)
          expect( $redis.get("#{customer_service.id}next_messageAt") ).to eq( (Time.now  + 1.minute).to_s )
        end
      end
    end
  end

  describe "self.compile_sms_message" do
    let(:clinical){ create(:user, :clinical) }
    let(:guardian){ create(:user, :guardian) }

    let!(:cs_user_message){ create(:message, sender: customer_service, conversation: guardian.family.conversation) }
    let!(:guardian_message_one){ create(:message, sender: guardian, conversation: guardian.family.conversation) }
    let!(:guardian_message_two){ create(:message, sender: guardian, conversation: guardian.family.conversation) }
    let!(:clinical_message){ create(:message, sender: clinical, conversation: guardian.family.conversation) }

    let(:compiled_message){ "#{guardian.first_name} #{guardian.last_name} sent you 1 messages! #{clinical.first_name} #{clinical.last_name} sent you 1 messages!"}

    before do
      guardian_message_two.update_columns(created_at: Time.now - 3.days)
    end

    it "should compile messages containing sender info and number of messages sent" do
      expect(Message.compile_sms_message(Time.now - 1.day, Time.now)).to eq(compiled_message)
    end
  end
end
