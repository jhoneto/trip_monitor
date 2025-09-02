class KitetripRoutesController < ApplicationController
  before_action :set_kitetrip_route, only: %i[ show edit update destroy ]

  # GET /kitetrip_routes or /kitetrip_routes.json
  def index
    @kitetrip_routes = KitetripRoute.all
  end

  # GET /kitetrip_routes/1 or /kitetrip_routes/1.json
  def show
  end

  # GET /kitetrip_routes/new
  def new
    @kitetrip_route = KitetripRoute.new
  end

  # GET /kitetrip_routes/1/edit
  def edit
  end

  # POST /kitetrip_routes or /kitetrip_routes.json
  def create
    @kitetrip_route = KitetripRoute.new(kitetrip_route_params)

    respond_to do |format|
      if @kitetrip_route.save
        format.html { redirect_to @kitetrip_route, notice: "Kitetrip route was successfully created." }
        format.json { render :show, status: :created, location: @kitetrip_route }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kitetrip_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitetrip_routes/1 or /kitetrip_routes/1.json
  def update
    respond_to do |format|
      if @kitetrip_route.update(kitetrip_route_params)
        format.html { redirect_to @kitetrip_route, notice: "Kitetrip route was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @kitetrip_route }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kitetrip_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kitetrip_routes/1 or /kitetrip_routes/1.json
  def destroy
    @kitetrip_route.destroy!

    respond_to do |format|
      format.html { redirect_to kitetrip_routes_path, notice: "Kitetrip route was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kitetrip_route
      @kitetrip_route = KitetripRoute.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def kitetrip_route_params
      params.expect(kitetrip_route: [ :kitetrip_id, :start_date, :end_date ])
    end
end
