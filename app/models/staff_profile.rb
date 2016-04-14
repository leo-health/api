class StaffProfile < ActiveRecord::Base
  belongs_to :staff, ->{ staff }, class_name: "User"
  belongs_to :practice
  after_commit :subscribe_to_athena, on: :create

  def subscribe_to_athena
    SyncProviderJob.new(self).subscribe_if_needed run_at: Time.now
  end
end
