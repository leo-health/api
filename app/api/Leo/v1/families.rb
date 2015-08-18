module Leo
  module V1
    class Families < Grape::API
      include Grape::Kaminari

      namespace "family" do
        before do
          authenticated
        end

        desc "Return the family and members of current user"
        get  do
          if current_user.has_role? :guardian
            present :family, current_user.family, with: Leo::Entities::FamilyEntity
          else
            error!({error_code: 422, error_message: "Current user is not a guardian"}, 422)
          end
        end
      end
    end
  end
end
