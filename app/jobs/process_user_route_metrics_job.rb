class ProcessUserRouteMetricsJob < ApplicationJob
  queue_as :default

  def perform(user_id, kitetrip_route_id)
    user = User.find(user_id)
    kitetrip_route = KitetripRoute.find(kitetrip_route_id)

    # Find or initialize the user route resume
    resume = UserRouteResume.find_or_initialize_by(
      user: user,
      kitetrip_route: kitetrip_route
    )

    # Get all route traces for this user and route, ordered by timestamp
    traces = UserRouteTrace.where(
      user: user,
      kitetrip_route: kitetrip_route
    ).order(:metric_date)

    return unless traces.exists?

    # Extract coordinates and timestamps for processing
    trace_data = traces.map do |trace|
      {
        coordinates: [ trace.longitude, trace.latitude ],
        timestamp: trace.metric_date,
        metadata: trace.metadata || {}
      }
    end

    # Calculate metrics
    metrics = calculate_route_metrics(trace_data)

    # Update the resume with calculated metrics
    resume.assign_attributes(
      executed_route_coordinates: trace_data.map { |data| data[:coordinates] },
      average_speed: metrics[:average_speed],
      max_speed: metrics[:max_speed],
      total_distance: metrics[:total_distance],
      total_time: metrics[:total_time],
      status: "closed"
    )

    resume.save!
  end

  private

  def calculate_route_metrics(trace_data)
    return default_metrics if trace_data.length < 2

    total_distance = 0.0
    speeds = []
    total_time = 0

    # Calculate metrics between consecutive points
    (1...trace_data.length).each do |i|
      prev_point = trace_data[i - 1]
      current_point = trace_data[i]

      # Calculate distance between points in kilometers
      distance = calculate_distance(
        prev_point[:coordinates][1], prev_point[:coordinates][0],
        current_point[:coordinates][1], current_point[:coordinates][0]
      )

      total_distance += distance

      # Calculate time difference in seconds
      time_diff = current_point[:timestamp] - prev_point[:timestamp]
      total_time += time_diff

      # Calculate speed in km/h if we have a time difference
      if time_diff > 0
        speed_kmh = (distance / (time_diff / 3600.0))
        # Filter out unrealistic speeds (over 200 km/h)
        speeds << speed_kmh if speed_kmh <= 200.0
      end
    end

    # Calculate average and max speeds
    average_speed = speeds.any? ? (speeds.sum / speeds.length).round(2) : 0.0
    max_speed = speeds.any? ? speeds.max.round(2) : 0.0

    {
      average_speed: average_speed,
      max_speed: max_speed,
      total_distance: total_distance.round(3),
      total_time: total_time.to_i
    }
  end

  def calculate_distance(lat1, lon1, lat2, lon2)
    # Haversine formula to calculate distance between two points on Earth
    rad_per_deg = Math::PI / 180
    rlat1 = lat1 * rad_per_deg
    rlat2 = lat2 * rad_per_deg
    rlat_delta = (lat2 - lat1) * rad_per_deg
    rlon_delta = (lon2 - lon1) * rad_per_deg

    a = Math.sin(rlat_delta / 2)**2 +
        Math.cos(rlat1) * Math.cos(rlat2) * Math.sin(rlon_delta / 2)**2
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    # Earth's radius in kilometers
    earth_radius_km = 6371.0
    earth_radius_km * c
  end

  def default_metrics
    {
      average_speed: 0.0,
      max_speed: 0.0,
      total_distance: 0.0,
      total_time: 0
    }
  end
end
