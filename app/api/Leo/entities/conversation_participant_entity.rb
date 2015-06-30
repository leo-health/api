module Leo
  module Entities
    class ConversationParticipantEntity < Grape::Entity
      expose :id
      expose :title
      expose :first_name
      expose :middle_initial
      expose :last_name
      expose :dob
      expose :sex
      expose :practice_id
      expose :family_id
      expose :primary_role
    end
  end
end
