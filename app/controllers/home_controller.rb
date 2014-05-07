class HomeController < ApplicationController
  def index
    @primary_event = Event.first
    @favorited_events = current_user.favorited_events - [@primary_event]
  end
end
