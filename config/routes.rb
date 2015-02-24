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
#             leo_sessions        /sessions                          Leo::Sessions
#                     root GET    /                                  home#index
#

Rails.application.routes.draw do
  get 'regisrations/create'

  get 'regisrations/sign_up'

  devise_for :users, :controllers => {registrations: 'registrations', sessions: 'sessions'}
  mount Leo::API => '/'
  #mount Leo::Sessions => '/s'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
