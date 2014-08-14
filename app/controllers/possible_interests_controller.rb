class PossibleInterestsController < ApplicationController
  respond_to :json

  def index
    tags = TagSource.admin.owned_tags.order('name')

    render json: { tags: construct_response_from(tags) }
  end

  private

  def construct_response_from(tags)
    tags.map do |tag|
      { id: tag.id, name: tag.name }
    end
  end
end
