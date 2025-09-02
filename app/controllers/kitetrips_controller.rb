class KitetripsController < ApplicationController
  before_action :set_kitetrip, only: %i[ show edit update destroy ]

  # GET /kitetrips or /kitetrips.json
  def index
    @kitetrips = Kitetrip.all
  end

  # GET /kitetrips/1 or /kitetrips/1.json
  def show
  end

  # GET /kitetrips/new
  def new
    @kitetrip = Kitetrip.new
  end

  # GET /kitetrips/1/edit
  def edit
  end

  # POST /kitetrips or /kitetrips.json
  def create
    @kitetrip = Kitetrip.new(kitetrip_params)

    respond_to do |format|
      if @kitetrip.save
        format.html { redirect_to @kitetrip, notice: "Kitetrip was successfully created." }
        format.json { render :show, status: :created, location: @kitetrip }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @kitetrip.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /kitetrips/1 or /kitetrips/1.json
  def update
    respond_to do |format|
      if @kitetrip.update(kitetrip_params)
        format.html { redirect_to @kitetrip, notice: "Kitetrip was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @kitetrip }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @kitetrip.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /kitetrips/1 or /kitetrips/1.json
  def destroy
    @kitetrip.destroy!

    respond_to do |format|
      format.html { redirect_to kitetrips_path, notice: "Kitetrip was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_kitetrip
      @kitetrip = Kitetrip.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def kitetrip_params
      params.expect(kitetrip: [ :name, :start_date, :end_date ])
    end
end
