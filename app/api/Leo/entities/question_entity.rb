module Leo
  module Entities
    class QuestionEntity < Grape::Entity
      expose :body
      expose :survey
      expose :question_type
      expose :media
      expose :answers
    end
  end
end
