# == Route Map
#
#                   Prefix Verb   URI Pattern                        Controller#Action
#      regisrations_create GET    /regisrations/create(.:format)     regisrations#create
#     regisrations_sign_up GET    /regisrations/sign_up(.:format)    regisrations#sign_up
#         new_user_session GET    /users/sign_in(.:format)           sessions#new
#             user_session POST   /users/sign_in(.:format)           sessions#create
#     destroy_user_session DELETE /users/sign_out(.:format)          sessions#destroy
#            user_password POST   /users/password(.:format)          devise/passwords#create
#        new_user_password GET    /users/password/new(.:format)      devise/passwords#new
#       edit_user_password GET    /users/password/edit(.:format)     devise/passwords#edit
#                          PATCH  /users/password(.:format)          devise/passwords#update
#                          PUT    /users/password(.:format)          devise/passwords#update
# cancel_user_registration GET    /users/cancel(.:format)            registrations#cancel
#        user_registration POST   /users(.:format)                   registrations#create
#    new_user_registration GET    /users/sign_up(.:format)           registrations#new
#   edit_user_registration GET    /users/edit(.:format)              registrations#edit
#                          PATCH  /users(.:format)                   registrations#update
#                          PUT    /users(.:format)                   registrations#update
#                          DELETE /users(.:format)                   registrations#destroy
#   accept_user_invitation GET    /users/invitation/accept(.:format) devise/invitations#edit
#   remove_user_invitation GET    /users/invitation/remove(.:format) devise/invitations#destroy
#          user_invitation POST   /users/invitation(.:format)        devise/invitations#create
#      new_user_invitation GET    /users/invitation/new(.:format)    devise/invitations#new
#                          PATCH  /users/invitation(.:format)        devise/invitations#update
#                          PUT    /users/invitation(.:format)        devise/invitations#update
#                  leo_api        /                                  Leo::API
#      grape_swagger_rails        /swagger                           GrapeSwaggerRails::Engine
#        letter_opener_web        /letter_opener                     LetterOpenerWeb::Engine
#                     root GET    /                                  home#index
#
# Routes for GrapeSwaggerRails::Engine:
#   root GET  /           grape_swagger_rails/application#index
#
# Routes for LetterOpenerWeb::Engine:
# clear_letters DELETE /clear(.:format)                 letter_opener_web/letters#clear
# delete_letter DELETE /:id/delete(.:format)            letter_opener_web/letters#destroy
#       letters GET    /                                letter_opener_web/letters#index
#        letter GET    /:id(/:style)(.:format)          letter_opener_web/letters#show
#               GET    /:id/attachments/:file(.:format) letter_opener_web/letters#attachment
#

Rails.application.routes.draw do
  get 'regisrations/create'
  get 'regisrations/sign_up'

  devise_for :users, :controllers => {registrations: 'registrations', sessions: 'sessions'}
  mount Leo::Root => '/'
  mount GrapeSwaggerRails::Engine => '/swagger'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  root 'home#index'
end
