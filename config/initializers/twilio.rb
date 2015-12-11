require 'twilio-ruby'
#TODO move twilio account credentials to aws
account_sid = "AC5173c53fcffeaf9858c213aa10fc53b3"
auth_token = "5e08c71d26aed79f44c019c89a41438b"
TWILIO_PHONE_NUMBER = "+7147930760"

TWILIO = Twilio::REST::Client.new account_sid, auth_token
