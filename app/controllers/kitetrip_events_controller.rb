class KitetripEventsController < ApplicationController
  before_action :set_kitetrip_event, only: %i[ show edit update destroy ]

  # GET /kitetrip_events or /kitetrip_events.json
  def index
    @kitetrip_events = KitetripEvent.all
  end

  # GET /kitetrip_events/1 or /kitetrip_events/1.json
  def show
  end

  # GET /kitetrip_events/new
  def new
    @kitetrip_event = KitetripEvent.new
  end

  # GET /kitetrip_events/1/edit
  def edit
  end

  # POST /kitetrip_events or /kitetrip_events.json
  def create
    @kitetrip_event = KitetripEvent.new(kitetrip_event_params)

    respond_to do |format|
      if @kitetrip_event.save
        format.html { redirect_to @kitetrip_event, notice: "Kitetrip event was successfully created." }
        format.json { render :show, status: :created, location: @kitetrip_event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kitetrip_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitetrip_events/1 or /kitetrip_events/1.json
  def update
    respond_to do |format|
      if @kitetrip_event.update(kitetrip_event_params)
        format.html { redirect_to @kitetrip_event, notice: "Kitetrip event was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @kitetrip_event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kitetrip_event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kitetrip_events/1 or /kitetrip_events/1.json
  def destroy
    @kitetrip_event.destroy!

    respond_to do |format|
      format.html { redirect_to kitetrip_events_path, notice: "Kitetrip event was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kitetrip_event
      @kitetrip_event = KitetripEvent.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def kitetrip_event_params
      params.expect(kitetrip_event: [ :kitetrip_id, :event_date, :title, :description ])
    end
end
