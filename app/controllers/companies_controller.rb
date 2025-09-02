class CompaniesController < BaseController
  before_action :set_company, only: %i[ show edit update ]

  # GET /companies or /companies.json
  def index
    @companies = current_user.companies
  end

  # GET /companies/1 or /companies/1.json
  def show
  end

  # GET /companies/1/edit
  def edit
  end

  # PATCH/PUT /companies/1 or /companies/1.json
  def update
    respond_to do |format|
      if @company.update(company_params)
        format.html { redirect_to @company, notice: "Company was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @company }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_company
      @company = current_user.companies.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def company_params
      params.expect(company: [ :name ])
    end
end
