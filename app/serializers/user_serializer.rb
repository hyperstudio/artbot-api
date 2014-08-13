class UserSerializer < ActiveModel::Serializer
  attributes \
    :id,
    :email,
    :authentication_token,
    :zipcode,
    :send_weekly_emails,
    :send_day_before_event_reminders,
    :send_week_before_close_reminders
end
