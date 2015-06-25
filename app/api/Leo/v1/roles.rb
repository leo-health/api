class Leo::V1::Roles < Grape::API
  version 'v1', using: :path, vendor: 'leo-health'
  format :json

  include Grape::Kaminari
  formatter :json, Leo::V1::SuccessFormatter
  error_formatter :json, Leo::V1::ErrorFormatter

  resource :roles do
    desc "Return all roles"
    get "/" do
      puts "In get roles"
      present :roles, Role.all, with: Leo::Entities::RoleEntity
    end
  end
end
