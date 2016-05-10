class StaffProfile < ActiveRecord::Base
  include RoleCheckable

  belongs_to :staff, ->{ staff }, class_name: "User"
  belongs_to :provider
  belongs_to :practice

  # Eventually role, avatar, etc should delegate to a Person
  belongs_to :avatar
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
