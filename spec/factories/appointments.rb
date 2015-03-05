# == Schema Information
#
# Table name: appointments
#
#  id                         :integer          not null, primary key
#  appointment_status         :string
#  athena_appointment_type    :string
#  leo_provider_id            :integer          not null
#  athena_provider_id         :integer
#  leo_patient_id             :integer          not null
#  athena_patient_id          :integer
#  booked_by_user_id          :integer          not null
#  rescheduled_appointment_id :integer
#  duration                   :integer          not null
#  appointment_date           :date             not null
#  appointment_start_time     :time             not null
#  frozenyn                   :boolean
#  leo_appointment_type       :string
#  athena_appointment_type_id :integer
#  family_id                  :integer          not null
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#

FactoryGirl.define do
  factory :appointment do
    appointment_status "MyString"
athena_appointment_type "MyString"
leo_provider_id 1
athena_provider_id 1
leo_patient_id 1
athena_patient_id 1
booked_by_user_id 1
rescheduled_appointment_id 1
duration 1
appointment_date "2015-03-03"
appointment_start_time "2015-03-03 18:12:45"
frozenyn false
leo_appointment_type "MyString"
athena_appointment_type_id 1
  end

end
