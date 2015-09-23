module Leo
  module V1
    class Avatars < Grape::API
      resource :avatars do
        authorize_routes!

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
          # avatar = patient.avatars.create(owner: patient, avatar: avatar_decoder(params[:avatar], patient))
          # if avatar.valid?
          avatar = patient.avatars.new(owner: patient)
          avatar.avatar = avatar_decoder(params[:avatar], patient)
          if avatar.save
            byebug
            present :avatar, avatar, with: Leo::Entities::AvatarEntity
          else
            error!({error_code: 422, error_message: avatar.errors.full_messages }, 422)
          end
        end
      end

      helpers do
        def avatar_decoder(avatar, patient)
          data = StringIO.new(Base64.decode64(avatar))
          data.class.class_eval { attr_accessor :original_filename, :content_type }
          data.original_filename = "patient#{patient.id}upload.png"
          data.content_type = "image/png"
          data
        end
      end
    end
  end
end
