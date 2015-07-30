Rails.application.routes.draw do
  require_relative '../app/api/Leo/root'

  # devise_for :users, :controllers => {registrations: 'registrations', sessions: 'sessions'}
  mount Leo::Root => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root 'home#index'
end
