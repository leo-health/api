class UserSurvey < ActiveRecord::Base
  belongs_to :user
  belongs_to :survey
  belongs_to :patient
  has_many :answers

  validates_presence_of :user, :survey
  after_update :upload_survey_to_athena

  def self.create_and_notify(user, patient, survey)
    if UserSurvey.create(user: user, patient: patient, survey: survey).valid?
      user.collect_device_tokens(:SurveyCards).map do |device_token|
        NewSurveyApnsJob.send(device_token)
      end
    end
  end

  def generate_survey_pdf
    template = Tilt::ERBTemplate.new(Rails.root.join('app', 'views', 'surveys', 'mchat.html.erb'))
    p = WickedPdf.new.pdf_from_string(template.render(self), {page_size: 'Letter'})
    debugger
  end


  def upload_survey_to_athena
    if completed_changed?(from: false, to: true)
      pdf = generate_survey_pdf
      connector = AthenaHealthApiHelper::AthenaHealthApiConnector.instance

    end
  end
end


# template = Tilt::ERBTemplate.new(Rails.root.join('app', 'views', 'vaccines', 'vaccines.html.erb'))
# if immunizations.count > 0
#   output = template.render(@patient)
#   WickedPdf.new.pdf_from_string(output, {page_size: 'Letter'})
