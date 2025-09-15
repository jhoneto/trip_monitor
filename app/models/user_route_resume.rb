class UserRouteResume < ApplicationRecord
  belongs_to :user
  belongs_to :kitetrip_route

  validates :average_speed, :max_speed, :total_distance, :total_time, presence: true
  validates :average_speed, :max_speed, :total_distance, :total_time, numericality: { greater_than_or_equal_to: 0 }

  # PostGIS geometry column
  # executed_route: LineString containing the actual route executed by the user

  # Main method for setting executed route coordinates (array of [longitude, latitude] points)
  def executed_route_coordinates=(coords_array)
    return unless coords_array.is_a?(Array) && coords_array.length >= 2
    return unless coords_array.all? { |c| c.is_a?(Array) && c.length == 2 }

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    points = coords_array.map { |lng, lat| factory.point(lng, lat) }

    self.executed_route = factory.line_string(points)
  end

  # Get all executed route coordinates as array of [longitude, latitude]
  def executed_route_coordinates
    return [] unless executed_route

    executed_route.points.map { |point| [ point.x, point.y ] }
  end

  # Get executed route points as individual Point geometries
  def executed_route_points
    return [] unless executed_route

    executed_route.points.to_a
  end

  # Get number of points in the executed route
  def points_count
    return 0 unless executed_route

    executed_route.num_points
  end

  # Calculate executed route distance in kilometers using PostGIS
  def executed_distance_km
    return nil unless executed_route

    # Use PostGIS ST_Length with spheroid for accurate distance calculation
    result = self.class.connection.execute(
      "SELECT ST_Length(ST_Transform(ST_GeomFromText('#{executed_route.as_text}', 4326), 3857)) / 1000.0 as distance_km"
    )
    result.first["distance_km"].to_f.round(2)
  rescue
    # Fallback to simple approximation if PostGIS query fails
    distance_degrees = executed_route.length
    (distance_degrees * 111.32).round(2)
  end

  # Get executed route bounds (bounding box)
  def bounds
    return nil unless executed_route

    # Calculate bounds from all points
    coordinates = executed_route_coordinates
    return nil if coordinates.empty?

    min_lng = coordinates.map(&:first).min
    max_lng = coordinates.map(&:first).max
    min_lat = coordinates.map(&:last).min
    max_lat = coordinates.map(&:last).max

    {
      southwest: [ min_lng, min_lat ],
      northeast: [ max_lng, max_lat ]
    }
  end

  # Virtual attribute for JSON coordinates (for form handling)
  def executed_route_coordinates_json
    executed_route_coordinates.to_json
  end

  def executed_route_coordinates_json=(json_string)
    return unless json_string.present?

    begin
      coords = JSON.parse(json_string)
      self.executed_route_coordinates = coords if coords.is_a?(Array)
    rescue JSON::ParserError
      # Invalid JSON, ignore silently or could add validation error
    end
  end

  # Format methods for display
  def formatted_average_speed
    "#{average_speed} km/h"
  end

  def formatted_max_speed
    "#{max_speed} km/h"
  end

  def formatted_total_distance
    "#{total_distance} km"
  end

  def formatted_total_time
    hours = total_time / 3600
    minutes = (total_time % 3600) / 60
    seconds = total_time % 60

    if hours >= 1
      "#{hours.to_i}h #{minutes.to_i}m"
    elsif minutes >= 1
      "#{minutes.to_i}m #{seconds.to_i}s"
    else
      "#{seconds.to_i}s"
    end
  end

  # Scopes for querying resumes
  scope :by_user, ->(user) { where(user: user) }
  scope :by_route, ->(route) { where(kitetrip_route: route) }
  scope :recent, -> { order(created_at: :desc) }
  scope :fastest_average, -> { order(average_speed: :desc) }
  scope :fastest_max, -> { order(max_speed: :desc) }
  scope :longest_distance, -> { order(total_distance: :desc) }
  scope :longest_time, -> { order(total_time: :desc) }
end