module Leo
  class Root < Grape::API
    require_relative 'v1/api'

    prefix :api
    mount Leo::V1::API
    mount Leo::Validators
  end
end
