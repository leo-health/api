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

        desc "Return an individual practice"
        get ":id" do
          present :practice, Practice.find(params[:id]), with: Leo::Entities::PracticeEntity
        end
      end
    end
  end
end
