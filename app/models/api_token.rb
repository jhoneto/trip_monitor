class ApiToken < ApplicationRecord
  belongs_to :user

  validates :token, presence: true, uniqueness: true
  validates :device_id, presence: true
  validates :expires_at, presence: true

  scope :active, -> { where('expires_at > ?', Time.current) }
  scope :expired, -> { where('expires_at <= ?', Time.current) }

  def expired?
    expires_at <= Time.current
  end

  def self.cleanup_expired
    expired.delete_all
  end
end
