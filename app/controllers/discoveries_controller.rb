class DiscoveriesController < ApplicationController
  before_filter :authenticate_user_from_token!

  respond_to :json

  def index
    events = scope.page(page_param).per(per_page_param)
    render_json_with_pagination_for(events, { root: :events })
  end

  private

  def scope
    if !current_user.methods.include?(:signed_in?)
      Event.current.order(:end_date)
    elsif current_user.signed_in?
      Event.recommended_for(current_user)
    end
  end
end
