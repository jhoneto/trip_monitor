class KitetripRoute < ApplicationRecord
  belongs_to :kitetrip

  validates :start_date, :end_date, presence: true
  validates :name, presence: true
  validate :end_date_after_start_date
  validate :route_has_minimum_points

  # PostGIS geometry columns
  # route_path: LineString containing all route points (the main route)
  # start_point: Point geometry for the starting location (derived from route_path)
  # end_point: Point geometry for the ending location (derived from route_path)

  # Main method for setting route coordinates (array of [longitude, latitude] points)
  def route_coordinates=(coords_array)
    return unless coords_array.is_a?(Array) && coords_array.length >= 2
    return unless coords_array.all? { |c| c.is_a?(Array) && c.length == 2 }

    factory = RGeo::Geographic.spherical_factory(srid: 4326)
    points = coords_array.map { |lng, lat| factory.point(lng, lat) }

    self.route_path = factory.line_string(points)

    # Automatically derive start and end points from the route
    self.start_point = points.first
    self.end_point = points.last
  end

  # Get all route coordinates as array of [longitude, latitude]
  def route_coordinates
    return [] unless route_path

    route_path.points.map { |point| [ point.x, point.y ] }
  end

  # Get start coordinates [longitude, latitude]
  def start_coordinates
    return nil unless start_point

    [ start_point.x, start_point.y ]
  end

  # Get end coordinates [longitude, latitude]
  def end_coordinates
    return nil unless end_point

    [ end_point.x, end_point.y ]
  end

  # Get all route points as individual Point geometries
  def route_points
    return [] unless route_path

    route_path.points.to_a
  end

  # Get number of points in the route
  def points_count
    return 0 unless route_path

    route_path.num_points
  end

  # Add a point to the route at a specific position (0-based index)
  def add_point_at(coordinates, index = -1)
    return false unless coordinates.is_a?(Array) && coordinates.length == 2

    current_coords = route_coordinates

    if index == -1 || index >= current_coords.length
      current_coords << coordinates
    else
      current_coords.insert(index, coordinates)
    end

    self.route_coordinates = current_coords
    true
  end

  # Remove a point from the route at a specific position (0-based index)
  def remove_point_at(index)
    current_coords = route_coordinates
    return false if index >= current_coords.length || current_coords.length <= 2

    current_coords.delete_at(index)
    self.route_coordinates = current_coords
    true
  end

  # Update a point in the route at a specific position
  def update_point_at(index, coordinates)
    return false unless coordinates.is_a?(Array) && coordinates.length == 2

    current_coords = route_coordinates
    return false if index >= current_coords.length

    current_coords[index] = coordinates
    self.route_coordinates = current_coords
    true
  end

  # Calculate route distance in kilometers using PostGIS
  def distance_km
    return nil unless route_path

    # Use PostGIS ST_Length with spheroid for accurate distance calculation
    result = self.class.connection.execute(
      "SELECT ST_Length(ST_Transform(ST_GeomFromText('#{route_path.as_text}', 4326), 3857)) / 1000.0 as distance_km"
    )
    result.first["distance_km"].to_f.round(2)
  rescue
    # Fallback to simple approximation if PostGIS query fails
    distance_degrees = route_path.length
    (distance_degrees * 111.32).round(2)
  end

  # Get route bounds (bounding box)
  def bounds
    return nil unless route_path

    # Calculate bounds from all points
    coordinates = route_coordinates
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

  # Get the center point of the route (midpoint)
  def center_point
    return nil unless route_path

    # For LineString, calculate the midpoint by getting the point at 50% of the length
    begin
      midpoint = route_path.point_n(route_path.num_points / 2)
      [ midpoint.x, midpoint.y ]
    rescue
      # Fallback: use bounds center
      route_bounds = bounds
      return nil unless route_bounds

      center_x = (route_bounds[:southwest][0] + route_bounds[:northeast][0]) / 2.0
      center_y = (route_bounds[:southwest][1] + route_bounds[:northeast][1]) / 2.0
      [ center_x, center_y ]
    end
  end

  # Virtual attribute for JSON coordinates (for form handling)
  def route_coordinates_json
    route_coordinates.to_json
  end

  def route_coordinates_json=(json_string)
    return unless json_string.present?

    begin
      coords = JSON.parse(json_string)
      self.route_coordinates = coords if coords.is_a?(Array)
    rescue JSON::ParserError
      # Invalid JSON, ignore silently or could add validation error
    end
  end

  # Create a route from an array of [longitude, latitude] coordinates
  def self.create_from_coordinates(attributes, coordinates)
    route = new(attributes)
    route.route_coordinates = coordinates
    route
  end

  # Scopes for querying routes by geographic area
  scope :within_bounds, ->(southwest, northeast) {
    where(
      "ST_Intersects(route_path, ST_MakeEnvelope(?, ?, ?, ?, 4326))",
      southwest[0], southwest[1], northeast[0], northeast[1]
    )
  }

  scope :near_point, ->(coordinates, distance_meters = 1000) {
    point_wkt = "POINT(#{coordinates[0]} #{coordinates[1]})"
    where(
      "ST_DWithin(ST_Transform(route_path, 3857), ST_Transform(ST_GeomFromText(?, 4326), 3857), ?)",
      point_wkt, distance_meters
    )
  }

  private

  def end_date_after_start_date
    return unless start_date && end_date

    errors.add(:end_date, "must be after start date") if end_date < start_date
  end

  def route_has_minimum_points
    return unless route_path

    if route_path.num_points < 2
      errors.add(:route_path, "must have at least 2 points")
    end
  end
end
