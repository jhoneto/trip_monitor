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
    @kitetrip_route = @kitetrip.kitetrip_routes.build(kitetrip_route_params_without_coordinates)
    
    # Debug logs
    Rails.logger.debug "=== ROUTE COORDINATES DEBUG ==="
    Rails.logger.debug "Params: #{params[:kitetrip_route]}"
    Rails.logger.debug "Coordinates JSON: #{params[:kitetrip_route][:route_coordinates_json]}"
    
    # Process route coordinates if provided
    process_route_coordinates
    
    respond_to do |format|
      if @kitetrip_route.save
        Rails.logger.debug "Route saved successfully with coordinates: #{@kitetrip_route.route_coordinates}"
        format.html { redirect_to [@kitetrip, @kitetrip_route], notice: "Rota criada com sucesso!" }
        format.json { render :show, status: :created, location: [@kitetrip, @kitetrip_route] }
      else
        Rails.logger.debug "Route save failed: #{@kitetrip_route.errors.full_messages}"
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kitetrip_route.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitetrips/:kitetrip_id/kitetrip_routes/1 or /kitetrips/:kitetrip_id/kitetrip_routes/1.json
  def update
    # Debug logs
    Rails.logger.debug "=== UPDATE ROUTE COORDINATES DEBUG ==="
    Rails.logger.debug "Params: #{params[:kitetrip_route]}"
    Rails.logger.debug "Coordinates JSON: #{params[:kitetrip_route][:route_coordinates_json]}"
    
    # Process route coordinates if provided
    process_route_coordinates
    
    respond_to do |format|
      if @kitetrip_route.update(kitetrip_route_params_without_coordinates)
        Rails.logger.debug "Route updated successfully with coordinates: #{@kitetrip_route.route_coordinates}"
        format.html { redirect_to [@kitetrip, @kitetrip_route], notice: "Rota atualizada com sucesso!", status: :see_other }
        format.json { render :show, status: :ok, location: [@kitetrip, @kitetrip_route] }
      else
        Rails.logger.debug "Route update failed: #{@kitetrip_route.errors.full_messages}"
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
      params.expect(kitetrip_route: [ :name, :description, :start_date, :end_date, :route_coordinates_json ])
    end

    # Parameters without coordinates (to avoid conflicts)
    def kitetrip_route_params_without_coordinates
      params.expect(kitetrip_route: [ :name, :description, :start_date, :end_date ])
    end

    # Process route coordinates from JSON
    def process_route_coordinates
      coordinates_json = params.dig(:kitetrip_route, :route_coordinates_json)
      
      Rails.logger.debug "Raw params: #{params}"
      Rails.logger.debug "Coordinates JSON param: #{coordinates_json}"
      Rails.logger.debug "Coordinates JSON present?: #{coordinates_json.present?}"
      Rails.logger.debug "Coordinates JSON class: #{coordinates_json.class}"
      
      if coordinates_json.present?
        begin
          coordinates = JSON.parse(coordinates_json)
          Rails.logger.debug "Parsed coordinates: #{coordinates}"
          Rails.logger.debug "Coordinates is array?: #{coordinates.is_a?(Array)}"
          Rails.logger.debug "Coordinates length: #{coordinates.length}"
          
          if coordinates.is_a?(Array) && coordinates.length >= 2
            Rails.logger.debug "Setting route coordinates: #{coordinates}"
            @kitetrip_route.route_coordinates = coordinates
            Rails.logger.debug "Route coordinates after setting: #{@kitetrip_route.route_coordinates}"
          else
            Rails.logger.debug "Invalid coordinates format or insufficient points"
            @kitetrip_route.errors.add(:route_coordinates, "deve ter pelo menos 2 pontos")
          end
        rescue JSON::ParserError => e
          Rails.logger.debug "JSON parse error: #{e.message}"
          @kitetrip_route.errors.add(:route_coordinates, "formato inválido de coordenadas")
        end
      else
        Rails.logger.debug "No coordinates provided"
      end
    end
end
