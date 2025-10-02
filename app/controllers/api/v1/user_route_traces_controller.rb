class Api::V1::UserRouteTracesController < Api::V1::BaseController
  def create
    @user_route_trace = current_user.user_route_traces.build(user_route_trace_params)

    if @user_route_trace.save
      render json: @user_route_trace, status: :ok
    else
      render json: { errors: @user_route_trace.errors }, status: :unprocessable_entity
    end
  end

  private

  def user_route_trace_params
    params.require(:user_route_trace).permit(:kitetrip_route_id, :latitude, :longitude, :metric_date, metadata: {})
  end
end
