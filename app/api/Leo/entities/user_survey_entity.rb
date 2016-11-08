module Leo
  module Entities
    class UserSurveyEntity < Grape::Entity
      expose :id
      expose :patient_id
      expose :user_id
      expose :survey, with: Leo::Entities::SurveyEntity
      expose :current_question_index
    end
  end
end
