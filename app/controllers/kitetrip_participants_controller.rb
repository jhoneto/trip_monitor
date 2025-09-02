class KitetripParticipantsController < ApplicationController
  before_action :set_kitetrip_participant, only: %i[ show edit update destroy ]

  # GET /kitetrip_participants or /kitetrip_participants.json
  def index
    @kitetrip_participants = KitetripParticipant.all
  end

  # GET /kitetrip_participants/1 or /kitetrip_participants/1.json
  def show
  end

  # GET /kitetrip_participants/new
  def new
    @kitetrip_participant = KitetripParticipant.new
  end

  # GET /kitetrip_participants/1/edit
  def edit
  end

  # POST /kitetrip_participants or /kitetrip_participants.json
  def create
    @kitetrip_participant = KitetripParticipant.new(kitetrip_participant_params)

    respond_to do |format|
      if @kitetrip_participant.save
        format.html { redirect_to @kitetrip_participant, notice: "Kitetrip participant was successfully created." }
        format.json { render :show, status: :created, location: @kitetrip_participant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kitetrip_participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitetrip_participants/1 or /kitetrip_participants/1.json
  def update
    respond_to do |format|
      if @kitetrip_participant.update(kitetrip_participant_params)
        format.html { redirect_to @kitetrip_participant, notice: "Kitetrip participant was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @kitetrip_participant }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kitetrip_participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kitetrip_participants/1 or /kitetrip_participants/1.json
  def destroy
    @kitetrip_participant.destroy!

    respond_to do |format|
      format.html { redirect_to kitetrip_participants_path, notice: "Kitetrip participant was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kitetrip_participant
      @kitetrip_participant = KitetripParticipant.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def kitetrip_participant_params
      params.expect(kitetrip_participant: [ :kitetrip_id, :user_id, :role ])
    end
end
