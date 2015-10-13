module Leo
  module Entities
    class SessionEntity < Grape::Entity
      expose :authentication_token
    end
  end
end
