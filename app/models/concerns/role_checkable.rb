module RoleCheckable
  extend ActiveSupport::Concern

  private
  def role_by_name?
    __callee__.to_s == role.name + "?"
  end

  included do
    Role.find_each do |role|
      check_method_name = (role.name.to_s + "?").to_sym
      alias_method check_method_name, :role_by_name?
      public check_method_name
    end
  end
end
