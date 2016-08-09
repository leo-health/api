require 'rails_helper'
require "cancan/matchers"

describe "User" do
  describe "abilities" do
    subject(:ability){ Ability.new(user) }
    let!(:user){ create(:user, :guardian) }
    let(:other_user){ create(:user, :guardian) }

    context "when user has the role guardian" do
      let(:patient){create(:patient, family: user.family)}

      describe "ability for user" do
        let!(:provider){build(:user, :clinical)}
        let!(:family_member){build(:user, family: user.family)}

        it{should be_able_to(:read, provider)}
        it{should be_able_to(:read, family_member)}
        it{should be_able_to(:update, family_member)}
        it{should be_able_to(:create, family_member)}
        it{should be_able_to(:destroy, family_member)}
      end

      describe "ability for Sessions" do
        it{should_not be_able_to(:read, Session.new)}
      end

      describe "ability for avatars" do
        let(:other_patient){create(:patient, family: other_user.family)}
        let!(:avatar){build(:avatar, owner: patient)}
        let!(:avatar_of_patient_from_other_family){build(:avatar, owner: other_patient)}

        it{should be_able_to(:create, avatar)}

        it{should_not be_able_to(:create, avatar_of_patient_from_other_family)}
      end

      describe "ability for Patient" do
        let(:patient_role){build(:role, :patient)}
        let!(:patient){build(:patient, family: user.family)}
        let!(:other_patient){build(:patient)}

        it{should be_able_to(:read, patient)}
        it{should be_able_to(:destroy, patient)}
        it{should be_able_to(:update, patient)}
        it{should be_able_to(:create, patient)}

        it{should_not be_able_to(:read, other_patient)}
        it{should_not be_able_to(:destroy, other_patient)}
        it{should_not be_able_to(:update, other_patient)}
        it{should_not be_able_to(:create, other_patient)}
      end

      describe "ability for Conversation" do
        let!(:conversation){build(:conversation, family: user.family)}
        let!(:other_conversation){build(:conversation)}

        it{should be_able_to(:read, conversation)}

        it{should_not be_able_to(:read, other_conversation)}
      end

      describe "ability for Messages" do
        let!(:message){build(:message, sender: user, conversation: user.family.conversation)}
        let!(:other_message){build(:message)}

        it{should be_able_to(:read, message)}
        it{should be_able_to(:create, message)}

        it{should_not be_able_to(:read, other_message)}
        it{should_not be_able_to(:create, other_message)}
      end

      describe "ability for Appointments" do
        # it{should be_able_to(:read, Appointment.new)}
      end

      describe "ability for Forms" do
        let(:form){ build(:form, patient: patient)}

        it{should be_able_to(:read, form)}
        it{should be_able_to(:update, form)}
        it{should be_able_to(:destroy, form)}
      end
    end

    context "when user has the role financial" do
      let!(:user){build(:user, :financial)}

      describe "ability for User" do
        let!(:provider){build(:user, :clinical)}

        it{should be_able_to(:read, provider)}
      end

      describe "ability for Conversation" do
        it{should be_able_to(:read, Conversation.new)}
        it{should be_able_to(:update, Conversation.new)}
      end

      describe "ability for Message" do
        it{should be_able_to(:create, Message.new)}
        it{should be_able_to(:read, Message.new)}
      end

      describe "ability for Appointments" do
        it{should be_able_to(:read, Appointment.new)}
      end

      describe "ability for Sessions" do
        it{should be_able_to(:read, Session.new)}
      end
    end

    context "when user has the role clinical" do
      let!(:user){build(:user, :clinical)}

      describe "ability for User" do
        let!(:provider){build(:user, :clinical)}

        it{should be_able_to(:read, provider)}
        it{should be_able_to(:update, provider)}

        it{should_not be_able_to(:create, provider)}
        it{should_not be_able_to(:destroy, provider)}
      end

      describe "ability for Conversation" do
        it{should be_able_to(:read, Conversation.new)}
        it{should be_able_to(:update, Conversation.new)}
      end

      describe "ability for Message" do
        it{should be_able_to(:create, Message.new)}
        it{should be_able_to(:read, Message.new)}
      end

      describe "ability for Appointments" do
        it{should be_able_to(:read, Appointment.new)}
      end

      describe "ability for Forms" do
        let(:form){ build(:form, patient: patient)}

        it{should be_able_to(:read, Form.new)}
        it{should be_able_to(:update, Form.new)}
        it{should be_able_to(:destroy, Form.new)}
      end

      describe "ability for Sessions" do
        it{should be_able_to(:read, Session.new)}
      end
    end

    context "when user has the role clinical_support" do
      let!(:user){build(:user, :clinical_support)}

      describe "ability for User" do
        let!(:provider){build(:user, :clinical)}

        it{should be_able_to(:read, provider)}
        it{should be_able_to(:update, provider)}
      end

      describe "ability for Conversation" do
        it{should be_able_to(:read, Conversation.new)}
        it{should be_able_to(:update, Conversation.new)}
      end

      describe "ability for Message" do
        it{should be_able_to(:create, Message.new)}
        it{should be_able_to(:read, Message.new)}
      end

      describe "ability for Appointments" do
        it{should be_able_to(:read, Appointment.new)}
      end

      describe "ability for Forms" do
        let(:form){ build(:form, patient: patient)}

        it{should be_able_to(:read, Form.new)}
        it{should be_able_to(:update, Form.new)}
        it{should be_able_to(:destroy, Form.new)}
      end

      describe "ability for Sessions" do
        it{should be_able_to(:read, Session.new)}
      end
    end

    context "when user has the role customer_service" do
      let!(:user){build(:user, :customer_service)}

      describe "ability for User" do
        let!(:provider){build(:user, :clinical)}

        it{should be_able_to(:read, provider)}

        it{should_not be_able_to(:update, provider)}
      end

      describe "ability for Conversation" do
        it{should be_able_to(:read, Conversation.new)}
        it{should be_able_to(:update, Conversation.new)}
      end

      describe "ability for Message" do
        it{should be_able_to(:create, Message.new)}
        it{should be_able_to(:read, Message.new)}
      end

      describe "ability for Forms" do
        it{should be_able_to(:read, Form.new)}
      end

      describe "ability for Sessions" do
        it{should be_able_to(:read, Session.new)}
      end
    end

    context "when user has the role operational" do
      let!(:user){build(:user, :operational)}

      describe "ability for Sessions" do
        it{should be_able_to(:read, Session.new)}
      end
    end
  end
end
