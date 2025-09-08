class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :authenticate_user!, only: [:login]

  def login
    user = User.find_by(email: login_params[:email])
    
    if user&.valid_password?(login_params[:password])
      device_id = login_params[:device_id] || 'unknown'
      result = JwtService.generate_token_for_user(user, device_id)
      
      render json: {
        status: 'success',
        message: 'Login successful',
        data: {
          user: {
            id: user.id,
            email: user.email,
            created_at: user.created_at
          },
          token: result[:token],
          expires_at: result[:api_token].expires_at
        }
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  def logout
    token = request.headers['Authorization']&.split(' ')&.last
    
    if token && JwtService.revoke_token(token)
      render json: {
        status: 'success',
        message: 'Logout successful'
      }, status: :ok
    else
      render json: {
        status: 'error',
        message: 'Invalid token or already logged out'
      }, status: :unauthorized
    end
  end

  def logout_all
    JwtService.revoke_all_user_tokens(current_user)
    
    render json: {
      status: 'success',
      message: 'Logged out from all devices'
    }, status: :ok
  end

  private

  def login_params
    params.require(:user).permit(:email, :password, :device_id)
  end
end