class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def has_role?(current_user, role)
    return current_user.roles.find_by_name(role.to_s.camelize)
  end

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  private

  def current_user
    super || Guest.new
  end

  def authenticate_user_from_token!
    authentication_token = params[:authentication_token].presence
    user = authentication_token && User.find_by_authentication_token(authentication_token.to_s)

    if user
      sign_in user, store: false
    end
  end

  def per_page_param
    params.fetch(:per_page, 5)
  end

  def page_param
    params.fetch(:page, 1)
  end

  def meta_hash_for(items)
    {
      current_page: items.current_page,
      next_page: items.next_page,
      prev_page: items.prev_page,
      per_page: per_page_param,
      total_pages: items.total_pages
    }
  end

  def render_json_with_pagination_for(items)
    render(
      json: items,
      meta: meta_hash_for(items)
    )
  end
end
