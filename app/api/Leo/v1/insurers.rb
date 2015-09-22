module Leo
  module V1
    class Insurers < Grape::API
      resource :insurers do
        desc "Return all insurers with plans"
        get do
          present :insurers, Insurer.all, with: Leo::Entities::InsurerEntity
        end
      end
    end
  end
end
