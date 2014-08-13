class LocationsController < ApplicationController
  respond_to :json

  def index
    locations = Location.all.page(page_param).per(per_page_param)
    render_json_with_pagination_for(locations)
  end

  def show
    location = Location.find(params[:id])
    respond_with location
  end
end
