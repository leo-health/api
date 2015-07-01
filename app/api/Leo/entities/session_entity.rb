module Leo
  module Entities
    class SessionEntity < Grape::Entity
      expose :id
      expose :user, if: lambda { |instance, options| options[:user] } do |instance, options|
        options[:user]
      end
      expose :authentication_token
      expose :os_version
    end
  end
end
