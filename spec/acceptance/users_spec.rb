require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Users" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let!(:default_practice) { create(:practice) }
  let!(:role){create(:role, :guardian)}
  let(:user){create(:user)}
  let(:session){user.sessions.create}
  let(:id){ user.id }
  let(:authentication_token){ session.authentication_token }

  get "/api/v1/staff" do
    parameter :authentication_token, "Authentication Token", required: true

    let!(:clinical){ create(:user, :clinical) }
    let(:raw_post){ params.to_json }

    example "get all staff" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  post "/api/v1/sign_up" do
    parameter :first_name, "First Name", required: true
    parameter :last_name, "Last Name", required: true
    parameter :email, "Email", required: true
    parameter :password, "Password", required: true
    parameter :phone, "Phone", required: true
    parameter :birth_date
    parameter :sex
    parameter :family_id
    parameter :middle_initial
    parameter :title
    parameter :suffix

    let(:first_name){ "Big" }
    let(:last_name){ "Tree" }
    let(:email){ "BigTree@yahoo.com" }
    let(:password){ "password" }
    let(:phone){ "1234567890" }
    let(:raw_post) { params.to_json }

    example "create a user with provided params" do
      explanation "This is different from sign up through enrollment"
      do_request
      expect(response_status).to eq(201)
    end
  end

  post "/api/v1/users" do
    parameter :authentication_token, "Enrollment Token", required: true
    parameter :first_name, "First Name", required: true
    parameter :last_name, "Last Name", required: true
    parameter :phone, "Phone", required: true
    parameter :birth_date
    parameter :sex
    parameter :family_id
    parameter :middle_initial
    parameter :title
    parameter :suffix

    let(:enrollment){create(:enrollment, email: "bigtree@gmail.com", password: "password")}

    let(:first_name){ "Big" }
    let(:last_name){ "Tree" }
    let(:email){ "BigTree@yahoo.com" }
    let(:password){ "password" }
    let(:phone){ "1234567890" }
    let(:authentication_token){ enrollment.authentication_token }
    let(:raw_post) { params.to_json }

    example "create a user from enrollment record" do
      do_request
      expect(response_status).to eq(201)
    end
  end

  get "/api/v1/users/:id" do
    parameter :id, "User Id", required: true
    parameter :authentication_token, "Authentication Token", required: true

    let(:raw_post){ params.to_json }

    example "get an individual user" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  put "/api/v1/users/:id" do
    parameter :id, "User Id", required: true
    parameter :authentication_token, "Authentication Token", required: true
    parameter :email, "Email", required: true

    let(:email){ "new_email@yafoo.com" }
    let(:raw_post){ params.to_json }


    example "update an individual user" do
      do_request
      expect(response_status).to eq(200)
    end
  end
end
