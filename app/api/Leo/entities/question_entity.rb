module Leo
  module Entities
    class QuestionEntity < Grape::Entity
      expose :id
      expose :survey_id
      expose :order
      expose :question_type
      expose :body
      expose :secondary
      expose :media
    end
  end
end
