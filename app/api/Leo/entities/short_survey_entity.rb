module Leo
  module Entities
    class ShortSurveyEntity < Grape::Entity
      expose :name
      expose :description
      expose :survey_type
      expose :prompt
      expose :instruction
      expose :media
      expose :private
      expose :required
      expose :reason
      expose :expiration_datetime
      expose :user_surveys
    end
  end
end
