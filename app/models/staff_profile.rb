class StaffProfile < ActiveRecord::Base
  include RoleCheckable
  belongs_to :staff, ->{ staff }, class_name: "User"
  belongs_to :provider
  belongs_to :avatar
  after_update :check_on_call_status

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

  def check_on_call_status
    if on_call_changed? && staff && !staff.practice.in_office_hours?
      staff.practice.broadcast_practice_availability(staff.practice.available?)
    end
  end
end
