class ApplicationController < ActionController::Base
  helper_method :current_user, :logged_in?
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  
  def logged_in?
    !!current_user
  end
  
  def require_user
    if !logged_in?
      flash[:danger] = "You need to be logged in to perform that action"
      redirect_to login_path
    end
  end

  private

  # Helper method to respond with different formats for Hotwire
  def respond_with_turbo_stream
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  # Helper method to handle flash messages for turbo requests
  def set_flash_message(type, message)
    if request.format.turbo_stream?
      flash.now[type] = message
    else
      flash[type] = message
    end
  end
end
