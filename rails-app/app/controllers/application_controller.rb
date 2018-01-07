class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def disable_cors
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, PUT, DELETE, GET, OPTIONS'
    headers['Access-Control-Request-Method'] = '*'
    headers['Access-Control-Allow-Headers'] = 'Origin, X-Requested-With, Content-Type, Accept, Authorization'
  end

  def render_not_found
    respond_to do |format|
      format.html { render file: File.join(Rails.root, 'public', '404.html'), status: 404 }
      format.json { render json: "", status: 404 }
    end
  end

end
