class UserSurvey < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :patient
  has_many :answers

  validates_presence_of :user, :survey

  def self.create_test
    create(
      user: User.find(13),
      patient: Patient.find(1),
      survey: Survey.first
    )
  end

  def self.create_and_notify(user, patient, survey)
    if UserSurvey.create(user: user, patient: patient, survey: survey).valid?
      user.collect_device_tokens(:SurveyCards).map do |device_token|
        NewSurveyApnsJob.send(device_token)
      end
    end
  end

  def current_question_index
    last_answer_question_number = answers.joins(:question)
      .maximum("questions.order") || -1
    last_answer_question_number + 1
  end
end
