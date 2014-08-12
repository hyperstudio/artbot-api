class TokensController < ApplicationController
  protect_from_forgery except: :create

  def create
    user = User.find_by(email: params[:email])

    if user.valid_password?(params[:password])
      render json: { authentication_token: user.authentication_token }
    else
      render json: { error: 'Authentication failed' }, status: :forbidden
    end
  end
end
