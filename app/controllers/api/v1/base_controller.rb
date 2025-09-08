class Api::V1::BaseController < ActionController::API
  before_action :authenticate_user!
  before_action :ensure_json_request

  respond_to :json

  private

  def ensure_json_request
    request.format = :json
  end

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    
    unless token
      render json: { error: "Missing authorization token" }, status: :unauthorized
      return
    end

    @current_user = JwtService.find_user_by_token(token)
    
    unless @current_user
      render json: { error: "Invalid or expired token" }, status: :unauthorized
    end
  end

  def current_user
    @current_user
  end
end