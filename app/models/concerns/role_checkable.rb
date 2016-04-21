module RoleCheckable
  extend ActiveSupport::Concern

  def has_role?(name)
    role.try(:name) == name.to_s
  end

  # TODO: refactor provider? to use clinical?
  def provider?
    clinical?
  end
  
  private
  def role_by_name?
    role.try(:name) && __callee__.to_s == role.name + "?"
  end

  included do
    Role.find_each do |role|
      check_method_name = (role.name.to_s + "?").to_sym
      alias_method check_method_name, :role_by_name?
      public check_method_name
    end
  end
end
