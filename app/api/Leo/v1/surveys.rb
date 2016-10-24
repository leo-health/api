module Leo
  module V1
    class Surveys < Grape::API
      resource :surveys do
        route_param :id do
          before do
            authenticated
          end

          desc "get a survey"
          get  do
            survey = Survey.find(params[:id])
            present :survey, survey, with: Leo::Entities::SurveyEntity
          end
        end
      end
    end
  end
end
