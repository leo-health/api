module Leo
  module V1
    class Answers < Grape::API
      resource :answers do
        before do
          authenticated
        end

        desc "create an answer"
        params do
          requires :user_survey_id, type: String, allow_blank: false
          requires :question_id, type: String, allow_blank: false
          requires :text, type: String
        end

        post do
          answer = Answer.create(params.except(:authentication_token))
          create_success answer
        end
      end
    end
  end
end
