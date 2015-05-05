# == Schema Information
#
# Table name: messages
#
#  id                    :integer          not null, primary key
#  sender_id             :integer
#  conversation_id       :integer
#  body                  :text
#  message_type          :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  escalated_to_id       :integer
#  resolved_requested_at :datetime
#  resolved_approved_at  :datetime
#  escalated_at          :datetime
#  escalated_by_id       :integer
#

require 'rails_helper'

RSpec.describe Message, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
