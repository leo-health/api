module Leo
  module V1
    class Forms < Grape::API
      include Grape::Kaminari

      resource :forms do
        helpers do
          params :form_params do
            requires :patient_id, type: Integer, allow_blank: false
            requires :title, type: String, allow_blank: false
            requires :image, type: String, allow_blank: false
            optional :notes, type: String
            optional :completed_by_id, type: Integer
          end
        end

        before do
          authenticated
        end

        desc "create a form"
        params do
          requires :patient_id, type: Integer, allow_blank: false
          requires :submitted_by_id, type: Integer, allow_blank: false
          requires :title, type: String, allow_blank: false
          requires :image, type: String, allow_blank: false
          optional :notes, type: String
        end

        post do
          params[:image] = image_decoder(params[:image])
          form = Form.new(declared(params, include_missing: false))
          render_success form
        end

        desc "show a form"
        get ":id" do
          if form = Form.find(params[:id])
            authorize! :read, form
            present :form, form, with: Leo::Entities::FormEntity
          end
        end

        desc "soft-delete a form"
        delete ":id" do
          delete_form
        end

        desc "update a form"
        params do
          use :form_params
        end

        put ":id" do
          update_form
        end
      end

      helpers do

        def delete_form
          form = Form.find(params[:id])
          form.destroy!
          return
        end

        def update_form
          ## TODO implement update_form
        end

        def image_decoder(image)
          data = StringIO.new(Base64.decode64(image))
          data.class.class_eval { attr_accessor :original_filename, :content_type }
          data.content_type = "image/png"
          data.original_filename = "uploaded_form.png"
          data
        end
      end
    end
  end
end
