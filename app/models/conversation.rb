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
	has_and_belongs_to_many :participants, -> {uniq}, class_name: 'User', join_table: 'conversations_participants', association_foreign_key: 'participant_id'
	has_and_belongs_to_many :children, -> {uniq}, class_name: 'User', join_table: 'conversations_children', association_foreign_key: 'child_id'


	after_initialize :load_initial_participants

	def load_initial_participants
		# TODO: Add a default admin staff
		# self.particpants << User.find_staff_for_user/family/child

		# TODO: Add a default physician
		# self.participants << User.find_physician_for_user/family/child

		# self.save
	end



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
