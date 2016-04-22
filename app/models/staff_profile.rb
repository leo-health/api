class StaffProfile < ActiveRecord::Base
  belongs_to :staff, ->{ staff }, class_name: "User"
  belongs_to :provider_sync_profile
  belongs_to :practice
end
