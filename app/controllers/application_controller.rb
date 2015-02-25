class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  acts_as_token_authentication_handler_for User

  # Security note: controllers with no-CSRF protection must disable the Devise fallback,
  # see #49 for details.
  # acts_as_token_authentication_handler_for User, fallback_to_devise: false

  # The token authentication requirement can target specific controller actions:
  # acts_as_token_authentication_handler_for User, only: [:create, :update, :destroy]
  # acts_as_token_authentication_handler_for User, except: [:index, :show]

  # Several token authenticatable models can be handled by the same controller.
  # If so, for all of them except the last, the fallback_to_devise should be disabled.
  #
  # Please do notice that the order of declaration defines the order of precedence.
  #
  # acts_as_token_authentication_handler_for Admin, fallback_to_devise: false
  # acts_as_token_authentication_handler_for SpecialUser, fallback_to_devise: false
  # acts_as_token_authentication_handler_for User # the last fallback is up to you

end
