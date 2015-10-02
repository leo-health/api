module Leo
  module V1
    class Roles < Grape::API
      include Grape::Kaminari

      resource :roles do
        before do
          authenticated
        end

        desc "Return all roles"
        get "/" do
          present :roles, Role.all, with: Leo::Entities::RoleEntity
        end
      end
    end
  end
end
