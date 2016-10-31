module Leo
  module Entities
    class AnswerEntity < Grape::Entity
      expose :user_survey, with: Leo::Entities::UserSurveyEntity
      expose :text
      expose :question, with: Leo::Entities::QuestionEntity
    end
  end
end
