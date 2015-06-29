module Leo
  module Entities
    class RoleEntity < Grape::Entity
      expose :id
      expose :name
    end
  end
end
