module Leo
  module Entities
    class SurveyEntity < Grape::Entity
      expose :name
      expose :display_name
      expose :description, as: :survey_description
      expose :survey_type
      expose :prompt
      expose :instructions
      expose :media
      expose :private
      expose :required
      expose :reason
      expose :questions, with: Leo::Entities::QuestionEntity
    end
  end
end
