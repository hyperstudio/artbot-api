class RegistrationsController < ApplicationController
  respond_to :json

  def create
    user = User.new(
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      zipcode: params[:zipcode]
    )
    if user.save
      render json: user
    else
      render json: user.errors, status: 422
    end
  end
end
