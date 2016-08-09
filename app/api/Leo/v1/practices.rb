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
        get ":id" do
          practice = Practice.find_by(id: params[:id])
          present :practice, practice, with: Leo::Entities::ShortPracticeEntity
        end
      end
    end
  end
end
