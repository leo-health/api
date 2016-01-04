module Leo
  module V1
    class Forms < Grape::API
      include Grape::Kaminari

      resource :forms do
        helpers do
          params :form_params do
            requires :patient_id, type: Integer, allow_blank: false
            requires :title, type: String, allow_blank: false
            requires :notes, type: String
            optional :completed_by_id, type: Integer
          end
        end

        before do
          authenticated
        end

        desc "create a form"
        params do
          use :form_params
        end

        post do
          create_form
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
        def create_form
          ## TODO implement create_form
        end

        def delete_form
          form = Form.find(params[:id])
          form.update_attributes(status: "deleted")
        end

        def update_form
          ## TODO implement update_form
        end
      end
    end
  end
end
