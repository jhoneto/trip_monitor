class KitetripParticipant < ApplicationRecord
  belongs_to :kitetrip
  belongs_to :user

  validates :role, presence: true, inclusion: { in: %w[participant organizer guide] }
  validates :user_id, uniqueness: { scope: :kitetrip_id, message: "já está participando desta viagem" }

  def role_humanized
    case role
    when 'participant'
      'Participante'
    when 'organizer'
      'Organizador'
    when 'guide'
      'Guia'
    else
      role.capitalize
    end
  end
end
