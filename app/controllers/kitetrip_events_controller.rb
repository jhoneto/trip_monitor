class KitetripEventsController < BaseController
  before_action :set_kitetrip
  before_action :set_kitetrip_event, only: %i[ show edit update destroy ]

  # GET /kitetrips/:kitetrip_id/kitetrip_events or /kitetrips/:kitetrip_id/kitetrip_events.json
  def index
    @kitetrip_events = @kitetrip.kitetrip_events
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_events/1 or /kitetrips/:kitetrip_id/kitetrip_events/1.json
  def show
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_events/new
  def new
    @kitetrip_event = @kitetrip.kitetrip_events.build
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_events/1/edit
  def edit
  end

  # POST /kitetrips/:kitetrip_id/kitetrip_events or /kitetrips/:kitetrip_id/kitetrip_events.json
  def create
    @kitetrip_event = @kitetrip.kitetrip_events.build(kitetrip_event_params)

    respond_to do |format|
      if @kitetrip_event.save
        format.html { redirect_to [@kitetrip, @kitetrip_event], notice: "Kitetrip event was successfully created." }
        format.json { render :show, status: :created, location: [@kitetrip, @kitetrip_event] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kitetrip_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitetrips/:kitetrip_id/kitetrip_events/1 or /kitetrips/:kitetrip_id/kitetrip_events/1.json
  def update
    respond_to do |format|
      if @kitetrip_event.update(kitetrip_event_params)
        format.html { redirect_to [@kitetrip, @kitetrip_event], notice: "Kitetrip event was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: [@kitetrip, @kitetrip_event] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kitetrip_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kitetrips/:kitetrip_id/kitetrip_events/1 or /kitetrips/:kitetrip_id/kitetrip_events/1.json
  def destroy
    @kitetrip_event.destroy!

    respond_to do |format|
      format.html { redirect_to kitetrip_kitetrip_events_path(@kitetrip), notice: "Kitetrip event was successfully destroyed.", status: :see_other }
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

    def set_kitetrip_event
      @kitetrip_event = @kitetrip.kitetrip_events.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def kitetrip_event_params
      params.expect(kitetrip_event: [ :event_date, :title, :description ])
    end
end
