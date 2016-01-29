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

TWILIO_PHONE_NUMBER = ENV['TWILIO_PHONE_NUMBER']

if Rails.env.test?
  TWILIO = FakeSms.new ENV['account_sid'], ENV['auth_token']
else
  TWILIO = Twilio::REST::Client.new ENV['account_sid'], ENV['auth_token']
end
