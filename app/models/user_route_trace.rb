class UserRouteTrace < ApplicationRecord
  belongs_to :user
  belongs_to :kitetrip_route

  validates :latitude, :longitude, presence: true
  validates :latitude, numericality: { greater_than_or_equal_to: -90, less_than_or_equal_to: 90 }
  validates :longitude, numericality: { greater_than_or_equal_to: -180, less_than_or_equal_to: 180 }

  after_create :broadcast_position_update
  after_create :create_resume

  def self.emulate_position_updates(kitetrip_rout_id)
    traces = where(kitetrip_route_id: kitetrip_rout_id).order(:created_at)
    traces.each do |trace|
      trace.broadcast_position_update
      sleep 1 # Simulate delay between updates
    end
  end

  def create_resume
    return if UserRouteResume.where(user: user, kitetrip_route: kitetrip_route).count.positive?

    UserRouteResume.create!(
      user: user,
      kitetrip_route: kitetrip_route,
      average_speed: 0.0,
      max_speed: 0.0,
      total_distance: 0.0,
      total_time: 0
    )
  end

  # private

  def broadcast_position_update
    broadcast_update_to(
      "position_#{kitetrip_route_id}_#{user_id}",
      target: "participant_#{user_id}",
      partial: "kitetrip_routes/participant_position",
      locals: {
        user_id: user_id,
        user_email: user.email,
        user_initial: user.email.first.upcase,
        latitude: latitude.to_f,
        longitude: longitude.to_f,
        timestamp: created_at.iso8601
      }
    )
  end
end
