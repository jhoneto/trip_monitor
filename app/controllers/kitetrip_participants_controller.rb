class KitetripParticipantsController < BaseController
  before_action :set_kitetrip
  before_action :set_kitetrip_participant, only: %i[ show edit update destroy ]

  # GET /kitetrips/:kitetrip_id/kitetrip_participants or /kitetrips/:kitetrip_id/kitetrip_participants.json
  def index
    @kitetrip_participants = @kitetrip.kitetrip_participants
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_participants/1 or /kitetrips/:kitetrip_id/kitetrip_participants/1.json
  def show
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_participants/new
  def new
    @kitetrip_participant = @kitetrip.kitetrip_participants.build
  end

  # GET /kitetrips/:kitetrip_id/kitetrip_participants/1/edit
  def edit
  end

  # POST /kitetrips/:kitetrip_id/kitetrip_participants or /kitetrips/:kitetrip_id/kitetrip_participants.json
  def create
    @kitetrip_participant = @kitetrip.kitetrip_participants.build(kitetrip_participant_params)

    respond_to do |format|
      if @kitetrip_participant.save
        format.html { redirect_to [@kitetrip, @kitetrip_participant], notice: "Kitetrip participant was successfully created." }
        format.json { render :show, status: :created, location: [@kitetrip, @kitetrip_participant] }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kitetrip_participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitetrips/:kitetrip_id/kitetrip_participants/1 or /kitetrips/:kitetrip_id/kitetrip_participants/1.json
  def update
    respond_to do |format|
      if @kitetrip_participant.update(kitetrip_participant_params)
        format.html { redirect_to [@kitetrip, @kitetrip_participant], notice: "Kitetrip participant was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: [@kitetrip, @kitetrip_participant] }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kitetrip_participant.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kitetrips/:kitetrip_id/kitetrip_participants/1 or /kitetrips/:kitetrip_id/kitetrip_participants/1.json
  def destroy
    @kitetrip_participant.destroy!

    respond_to do |format|
      format.html { redirect_to kitetrip_kitetrip_participants_path(@kitetrip), notice: "Kitetrip participant was successfully destroyed.", status: :see_other }
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

    def set_kitetrip_participant
      @kitetrip_participant = @kitetrip.kitetrip_participants.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def kitetrip_participant_params
      params.expect(kitetrip_participant: [ :user_id, :role ])
    end
end
