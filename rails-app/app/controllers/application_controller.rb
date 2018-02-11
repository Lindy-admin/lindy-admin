class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, prepend: true
  before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def render_not_found
    respond_to do |format|
      format.html { render file: File.join(Rails.root, 'public', '404.html'), status: 404 }
      format.json { render json: "", status: 404 }
    end
  end

end
