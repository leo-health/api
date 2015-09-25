module Leo
  module Entities
    class FullMessageEntity < Grape::Entity
      expose :system_message, using: Leo::Entities::PublicActivityEntity, if: Proc.new {|g| g[:system_message]}
      expose :regular_message, using: Leo::Entities::MessageEntity, if: Proc.new {|g| g[:regular_message]}
    end
  end
end
