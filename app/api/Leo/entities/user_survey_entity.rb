module Leo
  module Entities
    class UserSurveyEntity < Grape::Entity
      expose :patient_id
      expose :user_id
      expose :survey, with: Leo::Entities::SurveyEntity
      expose :id
    end
  end
end
