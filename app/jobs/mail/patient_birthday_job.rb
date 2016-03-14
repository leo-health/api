class PatientBirthdayJob < Struct.new(:guardian_id)
  def self.send(guardian_id, patient_id)
    Delayed::Job.enqueue(new(guardian_id, patient_id))
  end

  def perform
    user = User.find_by_id(guardian_id)
    patient = Patient.find_by_id(patient_id)
    UserMailer.patient_birthday(user, patient).deliver if user && patient
  end

  def queue_name
    'notification_email'
  end
end
