class KitetripParticipant < ApplicationRecord
  belongs_to :kitetrip
  belongs_to :user
  
  validates :role, presence: true, inclusion: { in: %w[participant organizer guide] }
  validates :user_id, uniqueness: { scope: :kitetrip_id, message: "is already participating in this trip" }
end
