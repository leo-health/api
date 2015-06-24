class RoleExists < Grape::Validations::Base
  def validate_param!(attr_name, params)
    if Role.where(name: params[attr_name].downcase).count == 0
      raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be a valid role"
    end
  end
end
