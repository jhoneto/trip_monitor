class Kitetrip < ApplicationRecord
  validates :name, presence: true

  belongs_to :company
  has_many :kitetrip_routes, dependent: :destroy
  has_many :kitetrip_participants, dependent: :destroy
  has_many :kitetrip_events, dependent: :destroy
  has_many :users, through: :kitetrip_participants
end
