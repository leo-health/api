require 'rails_helper'

describe Leo::V1::Answers do
  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let(:serializer){ Leo::Entities::AnswerEntity }


  describe "POST /api/v1/answers" do
    let(:question){ create(:question) }
    let(:survey){ question.survey }
    let!(:question_two){ create(:question, survey: survey) }
    let(:patient){create(:patient, family: user.family)}
    let(:user_survey){ UserSurvey.create(survey: survey, user: user, patient: patient) }

    def do_request
      params = {user_survey_id: user_survey.id, question_id: question.id, text: "test", authentication_token: session.authentication_token}
      post "/api/v1/answers", params
    end

    it "should create an answers" do
      do_request
      body = JSON.parse(response.body, symbolize_names: true )
      expect(response.status).to eq(201)
      expect(body[:data][:answer].as_json.to_json).to eq(serializer.represent(Answer.first).as_json.to_json)
    end
  end
end
