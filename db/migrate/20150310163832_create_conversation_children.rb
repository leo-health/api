class CreateConversationChildren < ActiveRecord::Migration
	def change
		create_table :conversations_children, id: false do |t|
			t.references :conversation
			t.references :child
		end
	end
end
