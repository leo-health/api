module Leo
  module Entities
    class ShortUserEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name
    end
  end
end
