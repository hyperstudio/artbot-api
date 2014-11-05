class EventsController < ApplicationController
  respond_to :json

  def index
    events = scope.page(page_param).per(per_page_param)

    render_json_with_pagination_for(events)
  end

  def show
    event = Event.find(params[:id])
    respond_with event
  end

  private

  def scope
    if params[:location_id]
      events = Location.find(params[:location_id]).events.current
      fill_with_dummies(events)
    elsif params[:latitude] && params[:longitude]
      if params[:radius].nil?
        params[:radius] = 10
      end
      events = Event.by_distance(params[:latitude], params[:longitude], params[:radius]).current
      fill_with_dummies(events)
    else
      Event.for_date(params[:year], params[:month], params[:day])
    end
  end
end
