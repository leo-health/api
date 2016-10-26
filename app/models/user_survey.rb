class UserSurvey < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :patient
  has_many :answers

  validates_presence_of :user, :survey

  def self.create_survey(user, patient, survey)
    if UserSurvey.create(user: user, patient: patient, survey: survey).valid?
      user.collect_device_tokens(:SurveyCards).map do |device_token|
        NewSurveyApnsJob.send(device_token)
      end
    end
  end
end
