module Leo
  module Entities
    class SessionEntity < Grape::Entity
      expose :user, using: UserEntity
      expose :authentication_token
    end
  end
end
