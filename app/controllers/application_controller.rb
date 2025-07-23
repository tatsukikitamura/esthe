class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def after_sign_out_path_for(resoure)
    root_path
  end
  def after_sign_in_path_for(resource)
    shops_path
  end

  def configure_permitted_parameters
    # /users/sign_up
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :username, :phone_number, :full_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end
end