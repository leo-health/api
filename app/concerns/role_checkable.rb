module RoleCheckable
  extend ActiveSupport::Concern

  def role_by_name?
    __callee__ == role.name
  end
  private :role_by_name?

  included do
    Role.find_each { |role| alias_method (role.name.to_s + "?").to_sym, :role_by_name? }
  end
end
