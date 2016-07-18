require 'airborne'
require 'rails_helper'

describe Leo::V1::Users do
  let(:user_params){{ first_name: "first_name",
                      last_name: "last_name",
                      email: "guardian@leohealth.com",
                      password: "password",
                      sex: "M",
                      phone: "1234445555",
                      vendor_id: "id"
  }}
  let!(:default_practice) { create(:practice) }
  let(:serializer){ Leo::Entities::UserEntity }

  describe "Get /api/v1/staff" do
    let(:guardian){ create(:user, :guardian) }
    let(:session){ guardian.sessions.create }
    let!(:clinical){ create(:user, :clinical) }

    def do_request
      get "/api/v1/staff", { authentication_token: session.authentication_token }
    end

    it "should return the staff users" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:staff].as_json.to_json).to eq(serializer.represent([clinical]).as_json.to_json)
    end
  end

  describe "Get /api/v1/search_user" do
    let(:serializer){ Leo::Entities::ShortUserEntity }
    let(:user){ create(:user, first_name: "test", last_name: "user") }
    let(:session){ user.sessions.create }

    def do_request
      get "/api/v1/search_user", { authentication_token: session.authentication_token, query: "test" }
    end

    it "should return the user has name matches the query" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:guardians].as_json.to_json).to eq(serializer.represent([user]).as_json.to_json)
    end
  end

  describe "Put /api/v1/convert_user" do
    def do_request
      put "/api/v1/convert_user", { invitation_token: user.invitation_token, first_name: "modified" }
    end

    context "convert a invited guardian" do
      let!(:primary_user){ create(:user) }
      let(:invited_onboarding_group){ create(:onboarding_group, :invited_secondary_guardian) }
      let(:user){ create(:user, :incomplete, invitation_token: "token", family: primary_user.family, onboarding_group: invited_onboarding_group)}

      it "should update invited guardian info and send a email to notify primary guardian" do
        expect{ do_request }.to change(Delayed::Job.where(queue: 'registration_email'), :count).by(1)
        expect(response.status).to eq(200)
        expect( user.reload.first_name ).to eq('modified')
      end
    end

    context "convert a exempted guardian" do
      let(:exempted_onboarding_group){ create(:onboarding_group, :generated_from_athena) }
      let!(:exempted_user){ create(:user, :valid_incomplete, invitation_token: "token", onboarding_group: exempted_onboarding_group)}

      def do_request
        put "/api/v1/convert_user", { invitation_token: exempted_user.invitation_token, first_name: "modified" }
      end

      it "should convert the exempted guardian to completed guardian" do
        expect(exempted_user.complete_status).to eq("valid_incomplete")
        do_request
        expect(response.status).to eq(200)
        expect(exempted_user.reload.complete_status).to eq("complete")
      end
    end
  end

  describe "GET /api/v1/confirm_email" do
    let(:user){create(:user)}

    before do
      current_time = Time.new(2016, 3, 4, 12, 0, 0, "-05:00")
      Timecop.freeze(current_time)
    end

    after do
      Timecop.return
    end

    def do_request
      get "/api/v1/confirm_email", { token: user.confirmation_token }
    end

    it "should confirm the user's account" do
      do_request
      expect(response.status).to eq(301)
      expect(response.header['Location']).to eq("http://localhost:8888/email/success")
      expect(user.reload.confirmed_at).to eq(Time.now)
    end
  end

  describe "PUT /api/v1/confirm_secondary_guardian" do
    let(:invited_secondary_guardian_group){ create(:onboarding_group, :invited_secondary_guardian)}
    let(:user){ create(:user, :valid_incomplete, onboarding_group: invited_secondary_guardian_group) }
    let!(:invitation_token){ user.invitation_token }

    def do_request
      put "/api/v1/confirm_secondary_guardian", { invitation_token: invitation_token }
    end

    it "should update secondary guardian to complete and destroy sessions" do
      expect(user.complete_status).to eq("valid_incomplete")
      do_request
      expect(response.status).to eq(200)
      expect(user.reload.complete_status).to eq("complete")
    end
  end

  describe "POST /api/v1/users" do
    let!(:guardian_role){create(:role, :guardian)}
    let(:serializer){ Leo::Entities::UserEntity }
    let(:user_params){{ first_name: "first_name",
                        last_name: "last_name",
                        phone: "1234445555",
                        sex: 'M',
                        email: 'abcd@test.com',
                        password: 'password',
                        vendor_id: '123143123',
                        device_type: 'phone',
                        os_version: 'yosimite',
                        platform: 'mac'
    }}

    def do_request
      post "/api/v1/users", user_params, format: :json
    end

    it "should create the user with a role, and return created user along with authentication_token" do
      expect{ do_request }.to change{ User.count }.from(0).to(1)
      expect(response.status).to eq(201)
      body = JSON.parse(response.body, symbolize_names: true)
      expect( body[:data][:user].as_json.to_json ).to eq( serializer.represent( User.first ).as_json.to_json )
    end
  end

  describe "DEPRECATED Put /api/v1/users" do
    let(:guardian){ create(:user, :guardian) }
    let(:session){ guardian.sessions.create }

    def do_request
      put "/api/v1/users", { authentication_token: session.authentication_token, first_name: "modified" }
    end

    it "should return the requested user" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(guardian.reload.first_name).to eq('modified')
      expect(body[:data][:user]).to eq(serializer.represent(guardian).as_json)
    end
  end

  describe "Put /api/v1/users/current" do
    let(:guardian){ create(:user, :guardian) }
    let(:session){ guardian.sessions.create }

    def do_request
      put "/api/v1/users/current", { authentication_token: session.authentication_token, first_name: "modified" }
    end

    it "should return the requested user" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(guardian.reload.first_name).to eq('modified')
      expect(body[:data][:user]).to eq(serializer.represent(guardian).as_json)
    end
  end

  describe "Get /api/v1/users/current" do
    let(:guardian){ create(:user, :guardian) }
    let(:session){ guardian.sessions.create }

    def do_request
      get "/api/v1/users/current", { authentication_token: session.authentication_token }
    end

    it "should return the requested user" do
      do_request
      expect(response.status).to eq(200)
      body = JSON.parse(response.body, symbolize_names: true )
      expect(body[:data][:user]).to eq(serializer.represent(guardian).as_json)
    end
  end
end
