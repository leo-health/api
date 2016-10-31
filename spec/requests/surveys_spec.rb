require 'rails_helper'

describe Leo::V1::Surveys do
  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let(:serializer){ Leo::Entities::SurveyEntity }


  describe "Get /api/v1/surveys/:id" do
    let(:survey){ create(:survey) }

    def do_request
      get "/api/v1/surveys/#{survey.id}", { authentication_token: session.authentication_token }
    end

    it "should return the requested survey" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:survey].as_json.to_json).to eq(serializer.represent(survey).as_json.to_json)
    end
  end
end
