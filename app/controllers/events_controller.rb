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
    #event[:related] = related(event)
    respond_with event
  end

  private

  def scope
    if params[:location_id]
      Location.find(params[:location_id]).events.current
    else
      Event.all
    end
  end

  def related(event, tries = 8)
    tag = event.select_best_tag(not_ids: params[:not_tags])
    unless Event.matching_tags([tag.id]) and tries > 0
      params[:not_tags] += tag.id
      return related(event, tries-1)
  end
end
