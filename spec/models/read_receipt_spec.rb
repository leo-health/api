# == Schema Information
#
# Table name: read_receipts
#
#  id             :integer          not null, primary key
#  message_id     :integer
#  participant_id :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'rails_helper'

RSpec.describe ReadReceipt, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
