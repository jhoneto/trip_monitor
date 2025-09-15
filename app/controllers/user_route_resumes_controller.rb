class UserRouteResumesController < BaseController
  before_action :set_user_route_resume, only: [:show]

  def show
    @kitetrip_route = @user_route_resume.kitetrip_route
    @kitetrip = @kitetrip_route.kitetrip
    @user = @user_route_resume.user

    # Check if user has access to this kitetrip
    unless @kitetrip.company.user == current_user || @kitetrip.kitetrip_participants.exists?(user: current_user)
      redirect_to kitetrips_path, alert: "Acesso negado."
      return
    end
  end

  # Action to list route resumes for a specific user in a kitetrip
  def index_for_user
    @kitetrip = Kitetrip.joins(company: :user).where(users: { id: current_user.id }).find(params[:kitetrip_id])
    @user = User.find(params[:user_id])

    # Get all routes for this kitetrip
    route_ids = @kitetrip.kitetrip_routes.pluck(:id)

    # Get user route resumes for these routes
    @resumes = UserRouteResume.includes(:kitetrip_route)
                             .where(user: @user, kitetrip_route_id: route_ids)
                             .order(:created_at)

    # Format for JSON response
    resumes_data = @resumes.map do |resume|
      {
        id: resume.id,
        route_name: resume.kitetrip_route.name,
        total_distance: resume.total_distance,
        average_speed: resume.average_speed,
        max_speed: resume.max_speed,
        formatted_total_time: resume.formatted_total_time,
        processed_at: resume.created_at.strftime("%d/%m/%Y às %H:%M")
      }
    end

    render json: resumes_data
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Não encontrado" }, status: :not_found
  end

  private

  def set_user_route_resume
    @user_route_resume = UserRouteResume.includes(:user, kitetrip_route: :kitetrip).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to kitetrips_path, alert: "Resumo de rota não encontrado."
  end
end