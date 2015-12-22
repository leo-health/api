require 'rails_helper'
require 'rspec_api_documentation/dsl'

resource "Messages" do
  header "Accept", "application/json"
  header "Content-Type", "application/json"

  let(:user){ create(:user) }
  let(:session){ user.sessions.create }
  let(:authentication_token){ session.authentication_token }
  let(:message_params){{ body: "test", type_name: "text", sender: user, conversation: user.family.conversation }}

  get "/api/v1/messages/:id" do
    parameter :id, "Message Id", :required => true
    parameter :authentication_token, "Authentication Token", :required => true

    let(:message){ Message.create(message_params) }
    let(:id){ message.id }
    let(:raw_post){ params.to_json }

    example "get an individual message by id" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  get "/api/v1/conversations/:conversation_id/messages" do
    parameter :conversation_id, "Conversation Id", :required => true
    parameter :authentication_token, "Authentication Token", :required => true
    parameter :page, "Page Number (default 1)"
    parameter :per_page, "Record Per Page (default 25)"
    parameter :offset, "The Offset to Start from (default: 0)"

    let(:encoded_image){ Rack::Test::UploadedFile.new(File.join(Rails.root, 'spec', 'support', 'Zen-Dog1.png')) }
    let(:photo_message_params){{ message_photo_attributes: { image: encoded_image },
                                 type_name: "image",
                                 sender: user,
                                 conversation: user.family.conversation }}

    let(:conversation_id){ user.family.conversation.id }
    let(:raw_post){ params.to_json }

    before do
      Message.create(message_params)
      Message.create(photo_message_params)
    end

    example "get all messages of a conversation" do
      do_request
      expect(response_status).to eq(200)
    end
  end

  post "/api/v1/conversations/:conversation_id/messages" do
    parameter :conversation_id, "Conversation Id", :required => true
    parameter :authentication_token, "Authentication Token", :required => true
    parameter :body, "Messaage Body/Encoded Image", :required => true
    parameter :type_name, "Type of Message (image/text)", :required => true

    let(:body){ "test" }
    let(:conversation_id){ user.family.conversation.id }
    let(:raw_post){ params.to_json }

    example "create a text message" do
      do_request(type_name: "text")
      expect(response_status).to eq(201)
    end

    example "create a photo message" do
      image = open(File.new(Rails.root.join('spec', 'support', 'Zen-Dog1.png'))){|io|io.read}
      encoded_image = Base64.encode64(image)
      do_request(type_name: "image", body: encoded_image)
      expect(response_status).to eq(201)
    end
  end
end
