class Api::V1::KitetripsController < Api::V1::BaseController
  before_action :set_kitetrip, only: [:show]

  def index
    @kitetrips = current_user.kitetrips.includes(:company)
    render :index
  end

  def show
    render :show
  end

  private

  def set_kitetrip
    @kitetrip = current_user.kitetrips.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Kitetrip not found" }, status: :not_found
  end
end