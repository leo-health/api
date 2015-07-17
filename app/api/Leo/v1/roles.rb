module Leo
  module V1
    class Roles < Grape::API
      version 'v1', using: :path, vendor: 'leo-health'
      format :json

      include Grape::Kaminari
      formatter :json, Leo::V1::SuccessFormatter
      error_formatter :json, Leo::V1::ErrorFormatter

      resource :roles do
        desc "Return all roles"
        get "/" do
          present :roles, Role.all, with: Leo::Entities::RoleEntity
        end
      end
    end
  end
end
