Rails.application.routes.draw do
  require_relative '../app/api/Leo/root'

  mount Leo::Root => '/'

  if Rails.env.development? || Rails.env.develop?
   mount Raddocs::App => "/docs"
  end

  root 'home#index'
end
