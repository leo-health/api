module Leo
  module Validators
    class ValidateEmail < Grape::Validations::Base
      #source of the regex https://github.com/balexand/email_validator
      def validate_param!(attr_name, params)
        unless !!( params[attr_name] =~ /\A\s*([^@\\s]{1,64})@((?:[-\p{L}\d]+\.)+\p{L}{2,})\s*\z/i )
          fail Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: 'Email format is not correct'
        end
      end
    end
  end
end
