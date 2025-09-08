class Api::V1::UsersController < Api::V1::BaseController
  def show
    render :show
  end

  def update
    if current_user.update(user_params)
      render :show
    else
      render json: {
        errors: current_user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :birthdate,
      :phone_number,
      :address,
      :city,
      :country,
      :state
    )
  end
end
