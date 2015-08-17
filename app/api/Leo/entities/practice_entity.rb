module Leo
  module Entities
    class PracticeEntity < Grape::Entity
      expose :id
      expose :address_line_1
      expose :address_line_2
      expose :city
      expose :state
      expose :zip
      expose :fax
      expose :phone
      expose :email
      expose :staff, with: Leo::Entities::UserEntity
    end
  end
end
