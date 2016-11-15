require 'rails_helper'

RSpec.describe UserSurvey, type: :model do
  describe "relations" do
    it{ is_expected.to belong_to(:user) }
    it{ is_expected.to belong_to(:survey) }
    it{ is_expected.to belong_to(:patient) }
    it{ is_expected.to have_many(:answers) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:survey) }
  end

  describe "callbacks" do
    describe "after update" do
      let(:user_survey){ create(:user_survey) }
      let!(:connector) {AthenaHealthApiHelper::AthenaHealthApiConnector.instance}

      before do
        allow(connector.connection).to receive("authenticate").and_return('token')
        allow(connector.connection.connection).to receive("request").and_return(Struct.new(:code).new(200))
      end

      it "should email provider after survey uploaded" do
        user_survey.update_attributes(completed: true)
        expect( Delayed::Job.where(queue: "notification_email").last.handler.strip.include?('NotifyCompletedSurveyJob')).to eq(true)
      end
    end
  end

  describe ".create_and_notify" do
    let(:user){ create(:user) }
    let!(:session){ user.sessions.create(
      client_version: '1.5.1',
      platform: 'ios',
      device_token: 'token'
    )}
    let(:survey){ create(:survey) }
    let(:patient){ create(:patient) }

    it "should create a survey the specific patient and user" do
       expect{ UserSurvey.create_and_notify(user, patient, survey) }.to change(UserSurvey, :count).by(1)
    end

    it "should create a notification for user" do
      expect{ UserSurvey.create_and_notify(user, patient, survey) }.to change(Delayed::Job.where(queue: 'apns_notification'), :count).by(1)
    end
  end

  describe ".calculate_mchat_score" do
    let(:user_survey){ create(:user_survey) }

    context "positive questions" do
      let!(:positive_question){ create(:question, order: MCHAT_POSITIVE_QUESTIONS.sample, survey: user_survey.survey) }
      let!(:answer){ create(:answer, user_survey: user_survey, question: positive_question, text: 'yes') }

      it "should score one point if answer yes" do
        expect(user_survey.calculate_mchat_score).to eq(1)
      end
    end

    context "negtive questions" do
      let!(:negative_question){ create(:question, order: ((1..20).to_a - MCHAT_POSITIVE_QUESTIONS).sample, survey: user_survey.survey) }
      let!(:answer){ create(:answer, user_survey: user_survey, question: negative_question, text: 'no') }

      it "should score one point if answer no" do
        expect(user_survey.calculate_mchat_score).to eq(1)
      end
    end
  end

  describe ".calculate risk level" do
    let(:user_survey){ create(:user_survey) }

    it "should return low risk if score is lower than 3" do
      expect(user_survey.calculate_risk_level(2)).to eq('Low Risk')
    end

    it "should return medium risk if score is lower than 8" do
      expect(user_survey.calculate_risk_level(7)).to eq('Medium Risk')
    end

    it "should return high risk if score is lower than 21" do
      expect(user_survey.calculate_risk_level(20)).to eq('High Risk')
    end

    it "should return error if the score is out of above scope" do
      expect(user_survey.calculate_risk_level(22)).to eq('Error Occurred')
    end
  end
end
