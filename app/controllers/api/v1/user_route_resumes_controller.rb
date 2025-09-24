class Api::V1::UserRouteResumesController < Api::V1::BaseController
  before_action :set_kitetrip_route, only: [ :show, :process_metrics ]

  def show
    @user_route_resume = current_user.user_route_resumes.find_by(kitetrip_route: @kitetrip_route)

    if @user_route_resume
      render json: format_user_route_resume(@user_route_resume)
    else
      render json: { error: "Resume not found for this route" }, status: :not_found
    end
  end

  def process_metrics
    ProcessUserRouteMetricsJob.perform_later(current_user.id, @kitetrip_route.id)

    render json: {
      message: "Metrics processing started",
      user_id: current_user.id,
      kitetrip_route_id: @kitetrip_route.id
    }, status: :accepted
  end

  private

  def set_kitetrip_route
    @kitetrip_route = KitetripRoute.find(params[:kitetrip_route_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Route not found" }, status: :not_found
  end

  def format_user_route_resume(resume)
    {
      id: resume.id,
      kitetrip_route_id: resume.kitetrip_route_id,
      status: resume.status,
      average_speed: resume.average_speed,
      max_speed: resume.max_speed,
      total_distance: resume.total_distance,
      total_time: resume.total_time,
      executed_route_coordinates: resume.executed_route_coordinates,
      executed_distance_km: resume.executed_distance_km,
      points_count: resume.points_count,
      bounds: resume.bounds,
      formatted: {
        average_speed: resume.formatted_average_speed,
        max_speed: resume.formatted_max_speed,
        total_distance: resume.formatted_total_distance,
        total_time: resume.formatted_total_time
      },
      created_at: resume.created_at,
      updated_at: resume.updated_at
    }
  end
end