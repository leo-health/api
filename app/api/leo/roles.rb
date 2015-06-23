module Leo
  module Entities
    class RoleEntity < Grape::Entity
      expose :id
      expose :name
    end
  end

  class Roles < Grape::API
    version 'v1', using: :path, vendor: 'leo-health'
    format :json
    prefix :api

    include Grape::Kaminari
    formatter :json, JSendSuccessFormatter
    error_formatter :json, JSendErrorFormatter

    resource :roles do
      desc "Return all roles"
      get "/" do
        puts "In get roles"
        present :roles, Role.all, with: Leo::Entities::RoleEntity
      end
    end
  end
end
