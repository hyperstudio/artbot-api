class HomeController < ApplicationController
  def index
    @primary_event = Event.first
  end
end
