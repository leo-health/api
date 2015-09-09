module Leo
  module V1
    class Insurers < Grape::API

      resource :insurers do
        before do
          authenticated
        end

        desc "Return all insurers with plans"
        get do
          present :insurers, Insurer.all, with: Leo::Entities::RoleEntity
        end
      end
    end
  end
end
