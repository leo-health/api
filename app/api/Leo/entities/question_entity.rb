module Leo
  module Entities
    class QuestionEntity < Grape::Entity
      expose :body
      expose :secondary
      expose :survey_id
      expose :question_type
      expose :media
    end
  end
end
