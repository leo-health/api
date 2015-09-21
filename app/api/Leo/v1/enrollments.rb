module Leo
  module V1
    class Enrollments < Grape::API
      resource :enrollments do
        desc "create an enrollment"
        params do
          requries :email, type: String, validate_email: true
          requires :password, type: String
          requires :first_name, type: String
          requires :last_name, type: String
        end
        post do

        end

        desc "update an enrollment"
        params do

        end

        put ":id" do

        end
      end
    end
  end
end
