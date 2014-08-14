class DiscoveriesController < ApplicationController
  respond_to :json

  def index
    events = scope.page(page_param).per(per_page_param)
    render_json_with_pagination_for(events, { root: :events })
  end

  private

  def scope
    if current_user.present?
      Event.recommended_for(current_user)
    else
      Event.current.order(:end_date)
    end
  end
end
