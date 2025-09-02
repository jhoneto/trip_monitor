class Company < ApplicationRecord
  validates :name, presence: true

  belongs_to :user
  has_many :kitetrips, dependent: :destroy
end
