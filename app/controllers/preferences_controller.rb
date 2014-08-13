class PreferencesController < ApplicationController
  before_filter :authenticate_user_from_token!

  respond_to :json

  def update
    if current_user.update(preferences_params)
      render json: current_user
    else
      render json: user.errors, status: 422
    end
  end

  def show
    render json: current_user
  end

  private

  def preferences_params
    params.permit(
      :send_weekly_emails,
      :send_day_before_event_reminders,
      :send_week_before_close_reminders,
      :password,
      :password_confirmation,
      :zipcode
    )
  end
end
