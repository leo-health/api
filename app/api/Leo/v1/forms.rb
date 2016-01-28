module Leo
  module V1
    class Forms < Grape::API
      include Grape::Kaminari

      resource :forms do
        before do
          authenticated
        end

        desc "create a form"
        params do
          requires :patient_id, type: Integer, allow_blank: false
          requires :title, type: String, allow_blank: false
          requires :image, type: String, allow_blank: false
          optional :notes, type: String
        end

        post do
          create_form
        end

        desc "show a form"
        get ":id" do
          show_form
        end

        desc "update a form"
        params do
          optional :patient_id, type: Integer, allow_blank: false
          optional :title, type: String, allow_blank: false
          optional :image, type: String, allow_blank: false
          optional :notes, type: String
          optional :status, type: String, allow_blank: false
        end

        put ":id" do
          update_form
        end

        desc "soft-delete a form"
        delete ":id" do
          delete_form
        end
      end

      helpers do
        def create_form
          params[:image] = image_decoder(params[:image])
          form = current_user.forms.new(declared(params, include_missing: false))
          create_success form
        end

        def show_form
          form = Form.find(params[:id])
          authorize! :read, form
          render_success form
        end

        def update_form
          form = Form.find(params[:id])
          authorize! :update, form
          update_success form, declared(params, include_missing: false).merge(submitted_by: current_user)
        end

        def delete_form
          form = Form.find(params[:id])
          form.destroy!
          return
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
