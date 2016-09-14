module Leo
  module V1
    class Practices < Grape::API
      resource :practices do
        before do
          authenticated
        end

        desc "Return all practices"
        get do
          present :practices, Practice.all, with: Leo::Entities::PracticeEntity
        end

        desc "Return the practice by id"
        params do
          optional :query, type: String
        end

        get ":id" do
          practice = Practice.find_by(id: params[:id])
          present :is_practice_open, practice.try(:in_office_hours?) and return if params[:query].try(:to_sym) == :is_open
          present :practice, practice, with: Leo::Entities::PracticeEntity
        end
      end
    end
  end
end
