Rails.application.routes.draw do
  require_relative '../app/api/Leo/root'

  # devise_for :users, :controllers => {registrations: 'registrations', sessions: 'sessions'}
  mount Leo::Root => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'

  root 'home#index'
end
