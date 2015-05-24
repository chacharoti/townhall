class ApplicationController < ActionController::Base
  before_filter :ensure_signup_complete, only: [:new, :create, :update, :destroy]
  before_filter :set_organization
  layout :layout_by_resource
    
  def ensure_signup_complete
    # Ensure we don't go into an infinite loop
    return if action_name == 'finish_signup'

    # Redirect to the 'finish_signup' page if the user
    # email hasn't been verified yet
    if current_user && !current_user.email_verified?
      redirect_to finish_signup_path(current_user)
    end
  end

  def after_sign_in_path_for(resource)
    logger.debug("voted: #{session[:voted]}")
    request.env['omniauth.origin'] || stored_location_for(resource) || root_path
  end

  def set_organization
    if Subdomain.matches?(request)
      @organization = Organization.friendly.find(request.subdomain)
    end
  end

  def page_not_found
    respond_to do |format|
      format.html { render template: 'errors/404', layout: 'layouts/error', status: 404 }
      format.all  { render nothing: true, status: 404 }
    end
  end

  protected

  def layout_by_resource
    if devise_controller? && resource_name == :admin_user
      "registrations"
    else
      "application"
    end
  end
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception

end