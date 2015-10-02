class CleanUsersTable < ActiveRecord::Migration
  def up
    remove_column :users, :invitation_token
    remove_column :users, :invitation_created_at
    remove_column :users, :invitation_sent_at
    remove_column :users, :invitation_accepted_at
    remove_column :users, :invitation_limit
    remove_column :users, :invited_by_id
    remove_column :users, :invited_by_type
    remove_column :users, :invitations_count
  end

  def down
    add_column :users, :invitation_token, :string
    add_column :users, :invitation_created_at, :datetime
    add_column :users, :invitation_sent_at, :datetime
    add_column :users, :invitation_accepted_at, :datetime
    add_column :users, :invitation_limit, :integer
    add_column :users, :invited_by_id, :integer
    add_column :users, :invited_by_type, :string
    add_column :users, :invitations_count, :integer, default: 0
    add_index :users, :invitation_token
    add_index :users, :invitations_count
    add_index :users, :invited_by_id
  end
end
