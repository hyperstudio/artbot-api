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
      Location.find(params[:location_id]).events.current
    else
      Event.for_date(params[:year], params[:month], params[:day]) 
    end
  end
end
