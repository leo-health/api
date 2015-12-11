require 'twilio-ruby'

class FakeSms
  Message = Struct.new(:from, :to, :body)

  cattr_accessor :messages
  self.messages = []

  def initialize(_account_sid, _auth_token)
  end

  def messages
    self
  end

  def create(from:, to:, body:)
    self.class.messages << Message.new(from: from, to: to, body: body)
  end
end

#TODO after move twilio account credentials to aws, need to change them to env variables, below is only a temp solution
if Rails.env.test?
  account_sid = "AC5173c53fcffeaf9858c213aa10fc53b3"
  auth_token = "5e08c71d26aed79f44c019c89a41438b"
  TWILIO_PHONE_NUMBER = "+15005550006"
  TWILIO = FakeSms.new account_sid, auth_token
else
  account_sid = "AC852cc8aec42adfc0b2b05f91d6f4494d"
  auth_token = "eb70d1ce739681f78325f28412e53531"
  TWILIO_PHONE_NUMBER = "+17147930760"
  TWILIO = Twilio::REST::Client.new account_sid, auth_token
end
