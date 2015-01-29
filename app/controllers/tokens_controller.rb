class TokensController < ApplicationController
  protect_from_forgery except: :create

  def create
    user = User.find_by(email: params[:email])
    if !user.present?
      render json: { email: ["not found"] }, status: 422
    elsif !user.valid_password?(params[:password])
      render json: { password: ["is invalid"] }, status: 422
    else
      render json: { authentication_token: user.authentication_token }
    end
  end
end
