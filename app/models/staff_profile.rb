class StaffProfile < ActiveRecord::Base
  include RoleCheckable

  belongs_to :staff, ->{ staff }, class_name: "User"
  belongs_to :provider_sync_profile
  belongs_to :practice

  # Eventually role, avatar, etc should delegate to a Person
  belongs_to :avatar
  def role
    staff.try(:role) || provider_sync_profile.try(:role)
  end

  def self.create_with_provider!(provider)
    self.create!(Person.writable_column_names.reduce({provider_sync_profile: provider}) { |memo, field|
      if provider.respond_to?(field)
        memo[field] = provider.send(field)
      end
      memo
    })
  end
end
