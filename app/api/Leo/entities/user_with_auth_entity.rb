module Leo
  module Entities
    class UserWithAuthEntity < Leo::Entities::UserEntity
      expose :authentication_token
    end
  end
end
