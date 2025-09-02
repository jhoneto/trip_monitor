class KitetripRoutesController < BaseController
  before_action :set_kitetrip
  before_action :set_kitetrip_route, only: %i[ show edit update destroy ]

  # GET /kitetrips/:kitetrip_id/kitetrip_routes or /kitetrips/:kitetrip_id/kitetrip_routes.json
  def index
    @kitetrip_routes = @kitetrip.kitetrip_routes
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_routes/1 or /kitetrips/:kitetrip_id/kitetrip_routes/1.json
  def show
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_routes/new
  def new
    @kitetrip_route = @kitetrip.kitetrip_routes.build
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_routes/1/edit
  def edit
  end

  # POST /kitetrips/:kitetrip_id/kitetrip_routes or /kitetrips/:kitetrip_id/kitetrip_routes.json
  def create
    @kitetrip_route = @kitetrip.kitetrip_routes.build(kitetrip_route_params)

    respond_to do |format|
      if @kitetrip_route.save
        format.html { redirect_to [@kitetrip, @kitetrip_route], notice: "Kitetrip route was successfully created." }
        format.json { render :show, status: :created, location: [@kitetrip, @kitetrip_route] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kitetrip_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitetrips/:kitetrip_id/kitetrip_routes/1 or /kitetrips/:kitetrip_id/kitetrip_routes/1.json
  def update
    respond_to do |format|
      if @kitetrip_route.update(kitetrip_route_params)
        format.html { redirect_to [@kitetrip, @kitetrip_route], notice: "Kitetrip route was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: [@kitetrip, @kitetrip_route] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kitetrip_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kitetrips/:kitetrip_id/kitetrip_routes/1 or /kitetrips/:kitetrip_id/kitetrip_routes/1.json
  def destroy
    @kitetrip_route.destroy!

    respond_to do |format|
      format.html { redirect_to kitetrip_kitetrip_routes_path(@kitetrip), notice: "Kitetrip route was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kitetrip
      @kitetrip = Kitetrip.joins(company: :user).where(users: { id: current_user.id }).find(params[:kitetrip_id])
    rescue ActiveRecord::RecordNotFound
      redirect_to kitetrips_path, alert: "Kitetrip not found."
    end

    def set_kitetrip_route
      @kitetrip_route = @kitetrip.kitetrip_routes.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def kitetrip_route_params
      params.expect(kitetrip_route: [ :start_date, :end_date ])
    end
end
