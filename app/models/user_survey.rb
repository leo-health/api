class UserSurvey < ActiveRecord::Base
  include ActionView::Helpers
  belongs_to :user
  belongs_to :survey
  belongs_to :patient
  has_many :answers, dependent: :destroy

  validates_presence_of :user, :survey
  after_update :upload_survey_and_email_provider

  def self.create_and_notify(user, patient, survey)
    if UserSurvey.create(user: user, patient: patient, survey: survey).valid?
      user.collect_device_tokens(:SurveyCards).map do |device_token|
        NewSurveyApnsJob.send(device_token)
      end
    end
  end

  def calculate_mchat_score
    answers = Answer.where(user_survey: self)
    positive_ans = answers.where(question_id: survey.questions.where(order: MCHAT_POSITIVE_QUESTIONS).pluck(:id))
    negative_ans = answers.where(question_id: survey.questions.where.not(order: MCHAT_POSITIVE_QUESTIONS).pluck(:id))
    positive_ans.inject(0){|score, ans| score += 1 if ans.text == 'yes'; score} +
      negative_ans.inject(0){|score, ans| score += 1 if ans.text == 'no'; score}
  end

  def calculate_risk_level(score)
    return 'Low Risk' if (score <= 2 && 0 <= score)
    return 'Medium Risk' if score <= 7
    return 'High Risk' if score <= 20
    return 'Error Occurred'
  end

  private

  def upload_survey_and_email_provider
    ActiveRecord::Base.transaction do
      return unless completed_changed?(from: false, to: true)
      survey_name = "Mchat#{Time.current.to_i}.pdf"
      AthenaHealthApiHelper::AthenaHealthApiConnector.instance.upload_survey(patient, generate_survey_pdf(survey_name))
      File.delete(Rails.root.join("public", "#{survey_name}"))
    end
    NotifyCompletedSurveyJob.send(patient_id)
  end

  def generate_survey_pdf(survey_name)
    template = Tilt::ERBTemplate.new(Rails.root.join('app', 'views', 'surveys', 'mchat.html.erb'))
    p = WickedPdf.new.pdf_from_string(template.render(self))
    File.open(Rails.root.join("public", "#{survey_name}"), 'wb'){ |file| file << p }
    Rails.root.join("public", "#{survey_name}")
  end

  def current_question_index
    last_answer_question_number = answers.joins(:question)
      .maximum("questions.order") || -1
    last_answer_question_number + 1
  end
end
