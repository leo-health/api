# == Schema Information
#
# Table name: conversations
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Conversation < ActiveRecord::Base
	has_many :messages
	has_and_belongs_to_many :participants, class_name: 'User', join_table: 'conversations_participants', association_foreign_key: 'participant_id'

end
