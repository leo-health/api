class RegistrationsController < Devise::RegistrationsController
	# clear_respond_to
	respond_to :json
	skip_before_filter :verify_authenticity_token, :only => :create

  def create
  	build_resource
  	logger.debug "Resource: #{resource.to_yaml}"
  	if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_up(resource_name, resource)
        return render :json => {:success => true}
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
        return render :json => {:success => true}
      end
    else
      clean_up_passwords resource
      return render :json => {:success => false, :errors => resource.errors}
    end
  end

  # Signs in a user on sign up. You can overwrite this method in your own
  # RegistrationsController.
  

  protected
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  def sign_up_params
  	params.permit(:first_name, :last_name, :email, :password, :password_confirmation, :dob, :role)
  end

  def account_update_params
    params.permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password, :dob, :role)
  end
end
