module Leo
  module V1
    class Surveys < Grape::API
      resource :surveys do
        route_param :id do
          before do
            authenticated
          end

          desc "get a survey"
          params do
            requires :patient_id, type: Integer, allow_blank: false
            requires :avatar, type: String, allow_blank: false
          end

          get  do

          end
        end
      end
    end
  end
end
