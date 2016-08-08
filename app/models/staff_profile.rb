class StaffProfile < ActiveRecord::Base
  include RoleCheckable
  belongs_to :staff, ->{ staff }, class_name: "User"
  belongs_to :provider
  belongs_to :avatar
  after_update :check_on_call_status
  validates_uniqueness_of :staff_id, allow_nil: true

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
    return unless (staff || staff.complete?)
    if on_call_changed?(from: true, to: false)
      update_columns(sms_enabled: false)
      staff.practice.broadcast_practice_availability if staff.practice.on_call_providers.count == 0
    elsif on_call_changed?(from: false, to: true)
      update_columns(sms_enabled: true)
      staff.practice.broadcast_practice_availability if staff.practice.on_call_providers.count == 1
    end
  end
end
