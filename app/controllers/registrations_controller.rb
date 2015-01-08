class RegistrationsController < ApplicationController
  include Devise::Controllers::Rememberable
  helper_method Devise::Controllers::Rememberable.instance_methods

  respond_to :json

  def show
    if User.find_by(email: params[:email]).present?
      head :ok
    else
      head :not_found
    end
  end

  def create
    user = User.new(
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      zipcode: params[:zipcode]
    )
    if user.save
      set_remember user
      render json: user
    else
      render json: user.errors, status: 422
    end
  end

  def update
    reset_password_token = request.headers['reset_password_token'] || params[:reset_password_token]
    if ! reset_password_token.present?
      render json: { error: 'reset_password_token not set' }, status: 422
    else
      user = User.find_by(reset_password_token: reset_password_token)
      if user.present?
        user.update(
          password: params[:password], 
          password_confirmation: params[:password_confirmation]
        )
        if user.save
          render json: user
        else
          render json: user.errors, status: 422
        end
      else
        render json: { error: 'User does not exist' }, status: :not_found
      end
    end
  end

  def send_reset_email
    user = User.find_by(email: params[:email])
    if user.present?
      user.send_reset_password_instructions
      head :ok
    else
      head :not_found
    end
  end
end
