# == Schema Information
#
# Table name: families
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Family < ActiveRecord::Base
	has_many :members, :class_name => 'User'

	def parents
		self.members.with_role :parent
	end

	def guardians
		self.members.with_role :guardian
	end

	def children
		self.members.with_role :child
	end
end
