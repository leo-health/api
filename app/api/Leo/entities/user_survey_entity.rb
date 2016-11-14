module Leo
  module Entities
    class UserSurveyEntity < Grape::Entity
      expose :id
      expose :patient_id
      expose :user_id
      expose :ios_display_name
      expose :survey, with: Leo::Entities::SurveyEntity
      expose :current_question_index

      def ios_display_name
        # TODO: remove hard coded MCHAT here, use DB for template string instead
        default_value = object.survey.name
        return default_value unless patient_id = object.try(:patient_id)
        return default_value unless first_name = Patient.find_by_id(patient_id).try(:first_name)
        return "M-CHAT for #{first_name}"
      end
    end
  end
end
