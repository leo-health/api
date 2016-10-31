module Leo
  module Entities
    class UserSurveyEntity < Grape::Entity
      expose :patient
      expose :user
      expose :survey
      expose :id, as: :user_survey_id
    end
  end
end
