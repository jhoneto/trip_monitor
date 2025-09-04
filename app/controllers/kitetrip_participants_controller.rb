class KitetripParticipantsController < BaseController
  before_action :set_kitetrip
  before_action :set_kitetrip_participant, only: %i[ show destroy update_role ]

  def index
    @kitetrip_participants = @kitetrip.kitetrip_participants.includes(:user)
  end

  def show
  end

  def new
    @kitetrip_participant = @kitetrip.kitetrip_participants.build
  end

  def create
    user = User.find_by(email: kitetrip_participant_params[:email])
    
    if user.nil?
      render json: { error: "Usuário não encontrado com este email" }, status: :unprocessable_entity
      return
    end

    @kitetrip_participant = @kitetrip.kitetrip_participants.build(
      user: user,
      role: kitetrip_participant_params[:role]
    )

    if @kitetrip_participant.save
      if request.xhr?
        render json: { 
          success: true, 
          message: "Participante adicionado com sucesso",
          participant: {
            id: @kitetrip_participant.id,
            name: user.email,
            role: @kitetrip_participant.role_humanized
          }
        }
      else
        redirect_to kitetrip_kitetrip_participants_path(@kitetrip), notice: "Participante adicionado com sucesso."
      end
    else
      if request.xhr?
        render json: { error: @kitetrip_participant.errors.full_messages.first }, status: :unprocessable_entity
      else
        render :new, status: :unprocessable_entity
      end
    end
  end

  def update_role
    if @kitetrip_participant.update(role: params[:role])
      if request.xhr?
        render json: { 
          success: true, 
          message: "Função alterada com sucesso",
          role_humanized: @kitetrip_participant.role_humanized
        }
      else
        redirect_to kitetrip_kitetrip_participants_path(@kitetrip), notice: "Função alterada com sucesso."
      end
    else
      if request.xhr?
        render json: { error: @kitetrip_participant.errors.full_messages.first }, status: :unprocessable_entity
      else
        redirect_to kitetrip_kitetrip_participants_path(@kitetrip), alert: "Erro ao alterar função."
      end
    end
  end

  def destroy
    @kitetrip_participant.destroy!
    
    if request.xhr?
      render json: { success: true, message: "Participante removido com sucesso" }
    else
      redirect_to kitetrip_kitetrip_participants_path(@kitetrip), notice: "Participante removido com sucesso."
    end
  end

  def search_users
    if params[:email].present?
      users = User.where("email ILIKE ?", "%#{params[:email]}%").limit(10)
      render json: users.map { |user| { id: user.id, email: user.email } }
    else
      render json: []
    end
  end

  private

  def set_kitetrip
    @kitetrip = Kitetrip.joins(company: :user).where(users: { id: current_user.id }).find(params[:kitetrip_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to kitetrips_path, alert: "Kitetrip not found."
  end

  def set_kitetrip_participant
    @kitetrip_participant = @kitetrip.kitetrip_participants.find(params[:id])
  end

  def kitetrip_participant_params
    params.require(:kitetrip_participant).permit(:email, :role)
  end
end
