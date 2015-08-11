Rails.application.routes.draw do
  require_relative '../app/api/Leo/root'

  mount Leo::Root => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'

  root 'home#index'
end
