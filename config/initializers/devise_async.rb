module Devise
  module Models
    module Confirmable
      alias_method :send_confirmation_instructions_without_delay, :send_confirmation_instructions
      handle_asynchronously :send_confirmation_instructions, queue: 'registration_email'
    end

    module Recoverable
      alias_method :send_reset_password_instructions_without_delay, :send_reset_password_instructions
      handle_asynchronously :send_reset_password_instructions, queue: 'registration_email'
    end
  end
end
