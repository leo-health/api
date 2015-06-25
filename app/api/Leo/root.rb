module Leo
  class Root < Grape::API
    prefix :api
    mount Leo::V1::Api
  end
end
