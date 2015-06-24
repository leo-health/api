class UserUnique < Grape::Validations::Base
  def validate_param!(attr_name, params)
    unless User.where(email: params[attr_name].downcase).count == 0
      raise Grape::Exceptions::Validation, params: [@scope.full_name(attr_name)], message: "must be unique"
    end
  end
end
