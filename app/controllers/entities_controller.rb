class EntitiesController < ApplicationController
  # GET /entities
  # GET /entities.json
  def index
    @entities = Entities.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @events }
    end
  end

  # GET /entities/1
  # GET /entities/1.json
  def show
    @entity = Entity.find(params[:id])
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @event }
    end
  end

  # GET /entities/import
  # POST /entities/import
  def import
    if params[:file]
      admin_mapper = AdminMapper.new
      admin_mapper.json_from_file_obj(params[:file])
      admin_mapper.process_result
      redirect_to root_url, notice: "Import successful"
    else
      respond_to do |format|
        format.html
      end
    end
  end
end