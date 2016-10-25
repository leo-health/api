module Leo
  module Entities
    class QuestionEntity < Grape::Entity
      expose :body
      expose :secondary
      expose :survey
      expose :question_type
      expose :media
    end
  end
end
