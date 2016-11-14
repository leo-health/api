module Leo
  module Entities
    class AnswerEntity < Grape::Entity
      expose :user_survey_id
      expose :text
      expose :question_id
    end
  end
end
