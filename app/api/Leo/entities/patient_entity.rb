module Leo
  module Entities
    class PatientEntity < Grape::Entity
      expose :id, :title, :first_name, :middle_initial, :last_name, :suffix, :sex, :family_id, :email, :role_id
      expose :role
      format_with(:iso_timestamp) { |dt| dt.iso8601 }
      with_options(format_with: :iso_timestamp) do
        expose :birth_date
      end
      expose :avatar

      private

      def role
        object.role.name
      end

      def avatar
        uri = URI(object.current_avatar.avatar.url) if object.current_avatar
        Rack::Utils.parse_query(uri.query).merge(base_url:"#{uri.scheme}://#{uri.host}") if uri
      end
    end
  end
end
