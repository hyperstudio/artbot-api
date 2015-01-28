class RegistrationsController < ApplicationController
  include Devise::Controllers::Rememberable
  helper_method Devise::Controllers::Rememberable.instance_methods

  respond_to :json

  def self.digest(raw)
    Devise.token_generator.digest(User, :reset_password_token, raw)
  end

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
    key = 'reset_password_token'
    reset_password_token = request.headers["HTTP_#{key.upcase}"] || params[key]
    user = User.reset_password_by_token({
      reset_password_token: reset_password_token, 
      password: params[:password], 
      password_confirmation: params[:password_confirmation]
    })
    if user.errors.empty?
      render json: user
    else
      render json: { error: user.errors }, status: 422
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
