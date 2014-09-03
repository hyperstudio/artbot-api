class TokensController < ApplicationController
  protect_from_forgery except: :create

  def create
    user = User.find_by(email: params[:email])
    if !user.present?
      render json: { error: 'User does not exist' }, status: :not_found
    elsif !user.valid_password?(params[:password])
      render json: { error: 'Authentication failed' }, status: :forbidden
    else
      render json: { authentication_token: user.authentication_token }
    end
  end
end
