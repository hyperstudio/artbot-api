class FavoritesController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!

  respond_to :json

  def index
    favorites = current_user.favorites.order('created_at desc').
      page(page_param).per(per_page_param)

    render_json_with_pagination_for(favorites)
  end

  def history
    past_favorites = current_user.favorites.for_past_events.page(page_param).per(per_page_param)

    render_json_with_pagination_for(past_favorites)
  end

  def create
    event = Event.find(params[:event_id])
    favorite = Favorite.create!(
      user: current_user, event: event, attended: params[:attended]
    )
    respond_with favorite
  end

  def update
    favorite = current_user.favorites.find(params[:id])

    if favorite.update(attended: params[:attended])
      render json: favorite
    else
      render json: favorite.errors, status: 422
    end
  end

  def destroy
    favorite = current_user.favorites.find(params[:id]).destroy

    respond_with favorite
  end
end
