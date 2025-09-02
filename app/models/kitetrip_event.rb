class KitetripEvent < ApplicationRecord
  belongs_to :kitetrip
  
  validates :event_date, :title, presence: true
end
