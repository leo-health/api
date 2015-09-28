require 'airborne'
require 'rails_helper'

describe Leo::V1::Insurers do
  let(:user){create(:user)}
  let(:insurer){ Insurer.create(insurer_name: "test")}
  let!(:insurance_plan){ insurer.insurance_plans.create(plan_name: "PPO")}
  let!(:serializer){ Leo::Entities::InsurerEntity }

  describe "Get /api/v1/insurers" do
    def do_request
      get "/api/v1/insurers"
    end

    it 'should return all the insurers along with insurance plans' do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:insurers].as_json.to_json).to eq(serializer.represent(Insurer.all).as_json.to_json)
    end
  end
end
