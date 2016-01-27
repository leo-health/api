module Leo
  module V1
    class Avatars < Grape::API
      resource :avatars do
        before do
          authenticated
        end

        desc "create avatar for patient"
        params do
          requires :patient_id, type: Integer, allow_blank: false
          requires :avatar, type: String, allow_blank: false
        end

        post authorize: [:create, Avatar] do
          patient = Patient.find(params[:patient_id])
          avatar = patient.avatars.new(owner: patient)
          avatar.avatar = image_decoder(params[:avatar])
          create_success avatar, session_device_type
        end
      end
    end
  end
end
