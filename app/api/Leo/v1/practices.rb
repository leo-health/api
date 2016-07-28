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

        desc "Return the practice of current user"
        get ":current" do
          present :practice, current_user.practice, with: Leo::Entities::PracticeEntity
        end
      end
    end
  end
end
