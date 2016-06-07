module RoleCheckable
  extend ActiveSupport::Concern

  # Required methods
  # role

  def has_role?(name)
    role.try(:name) == name.to_s
  end

  private
  def role_by_name?
    role.try(:name) && __callee__.to_s == role.name + "?"
  end

  included do
    roles = Role.all.map(&:name) | [:financial, :clinical_support, :customer_service, :guardian, :clinical, :bot, :operational].map(&:to_s)
    check_method_names = roles.map { |role| (role + "?").to_sym }
    check_method_names.each do |role_name|
      alias_method role_name, :role_by_name?
      public role_name
    end
  end
end
