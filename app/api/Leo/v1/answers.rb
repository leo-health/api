module Leo
  module V1
    class Answers < Grape::API
      resource :answers do
        before do
          authenticated
        end

        desc "create an answer"
        params do
          requires :user_id, type: String, allow_blank: false
          requires :question_id, type: String, allow_blank: false
          optional :choice_id, type: String
          optional :text, type: String
          at_least_one_of :choice_id, :text
        end

        post do
          answer = Answer.create(params.except(:authentication_token))
          create_success answer
        end
      end
    end
  end
end
