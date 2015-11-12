Rails.application.routes.draw do
  require_relative '../app/api/Leo/root'

  mount Leo::Root => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'
  mount Raddocs::App => "/docs"

  root 'home#index'
end
