class RoleExists < Grape::Validations::Base
  def validate_param!(attr_name, params)
    unless Role.find(params[attr_name])
      raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be a valid role"
    end
  end
end
