class EventsController < ApplicationController
  respond_to :json

  def index
    events = scope.
      for_year(params[:year]).
      for_month(params[:month]).
      for_day(params[:day]).
      page(page_param).per(per_page_param)

    render_json_with_pagination_for(events)
  end

  def show
    event = Event.find(params[:id])
    if params[:related]
      render json: {results: related(event)}
    else
      respond_with event
    end
  end

  private

  def scope
    if params[:location_id]
      Location.find(params[:location_id]).events.current
    else
      Event.all
    end
  end

  def related(event)
    event.related_events
  end
end
