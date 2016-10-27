module Leo
  module Entities
    class SurveyEntity < Grape::Entity
      expose :name
      expose :description
      expose :survey_type
      expose :prompt
      expose :instruction, as: :instructions
      expose :media
      expose :private
      expose :required
      expose :reason
      expose :questions, with: Leo::Entities::QuestionEntity
    end
  end
end
