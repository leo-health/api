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

  describe ".create_survey" do
    let(:user){ create(:user) }
    let!(:session){ user.sessions.create(
      client_version: '1.5.1',
      platform: 'ios',
      device_token: 'token'
    )}
    let(:survey){ create(:survey) }
    let(:patient){ create(:patient) }

    it "should create a survey the specific patient and user" do
       expect{ UserSurvey.create_survey(user, patient, survey) }.to change(UserSurvey, :count).by(1)
    end

    it "should create a notification for user" do
      expect{ UserSurvey.create_survey(user, patient, survey) }.to change(Delayed::Job.where(queue: 'apns_notification'), :count).by(1)
    end
  end
end
