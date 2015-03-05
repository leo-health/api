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



	def self.for_user(user)
		if user.has_role? :parent
			user.conversations 
			# TODO need to figure out how conversations will be shared across multiple parents
		elsif user.has_role? :guardian
			user.conversations
		elsif user.has_role? :child
			#TODO: Implement
		elsif user.has_role? :physician
			#TODO: Implement
		elsif user.has_role? :clinical_staff
			#TODO: Implement
		elsif user.has_role? :other_staff
			#TODO: Implement
		elsif user.has_role? :admin
			Conversation.all
		end
	end

end
