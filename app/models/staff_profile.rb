class StaffProfile < ActiveRecord::Base
  include RoleCheckable
  belongs_to :staff, ->{ staff }, class_name: "User"
  belongs_to :provider
  belongs_to :avatar
  after_update :check_on_call_status
  validates_uniqueness_of :staff_id

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

  private

  def check_on_call_status
    return unless on_call_changed? && staff && staff.practice.oncall_providers.count <= 1
    if on_call_changed?(from: true, to: false) && staff.practice.oncall_providers.count == 0
      staff.practice.broadcast_practice_availability
    elsif on_call_changed?(from: false, to: true) && staff.practice.oncall_providers.count >= 1
      staff.practice.broadcast_practice_availability
    end
  end
end
