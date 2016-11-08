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
      expose :image_name

      private

      def image_name
        "question#{object.order}"
      end
    end
  end
end
