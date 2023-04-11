# frozen_string_literal: true

class Employees::SessionsController < Devise::SessionsController
  before_action :avoid_double_session, only: [:new]
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def after_sign_in_path_for(resource)
    employee_menus_path
  end

  def avoid_double_session
    if admin_signed_in?
      redirect_to admin_menus_path, alert: "ログアウトしてください"
    end
  end
end
