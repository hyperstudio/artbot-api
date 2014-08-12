class FavoritesController < ApplicationController
  before_filter :authenticate_user_from_token!
  before_filter :authenticate_user!

  respond_to :json

  def index
    respond_with current_user.favorites
  end
end
