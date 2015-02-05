class InterestsController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  before_filter :authenticate_user_from_token!

  respond_to :json

  def create
    # Tags are validated to be owned by admin at the model level
    tag = ActsAsTaggableOn::Tag.find(params[:tag_id])

    interest = Interest.create!(
      user: current_user,
      tag: tag
    )
    respond_with interest
  end

  def index
    respond_with current_user.interests
  end

  def destroy
    interest = current_user.interests.find(params[:id]).destroy

    respond_with interest
  end

end
