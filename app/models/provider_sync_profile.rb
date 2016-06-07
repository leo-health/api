class ProviderSyncProfile < ActiveRecord::Base
  include RoleCheckable

  belongs_to :provider, ->{ provider }, class_name: "User"
  belongs_to :practice
  validates_uniqueness_of :athena_id, conditions: ->{ where.not(athena_id: 0) }
  after_commit :subscribe_to_athena, on: :create

  def subscribe_to_athena
    SyncProviderJob.new(self).subscribe_if_needed run_at: Time.now
  end

  belongs_to :avatar
  def role
    Role.clinical
  end
end
