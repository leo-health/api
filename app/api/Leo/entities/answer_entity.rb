module Leo
  module Entities
    class AnswerEntity < Grape::Entity
      expose :user, with: Leo::Entities::ShortUserEntity
      expose :choice
      expose :question, with: Leo::Entities::QuestionEntity
    end
  end
end
