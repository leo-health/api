class AddNullFalseOnEnrollmentVendorId < ActiveRecord::Migration
  def change
    change_column_null :enrollments, :vendor_id, false
  end
end
