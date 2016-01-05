class PatientBirthdayJob < Struct.new(:guardian_id)
  def self.send(guardian_id)
    Delayed::Job.enqueue(new(guardian_id))
  end

  def perform
    user = User.find_by_id(guardian_id)
    UserMailer.patient_birthday(user).deliver if user
  end
end
