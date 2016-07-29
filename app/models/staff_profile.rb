class StaffProfile < ActiveRecord::Base
  include RoleCheckable
  belongs_to :staff, ->{ staff }, class_name: "User"
  belongs_to :provider
  belongs_to :practice
  belongs_to :avatar
  scope :staff, -> { where(role: Role.staff_roles, complete_status: :complete) }
  scope :provider, -> { where(role: Role.provider_roles, complete_status: :complete) }

  def role
    staff.try(:role) || provider.try(:role)
  end

  def self.create_with_provider!(provider)
    self.create!(Person.writable_column_names.reduce({provider: provider}) { |memo, field|
      if provider.respond_to?(field)
        memo[field] = provider.send(field)
      end
      memo
    })
  end
end
