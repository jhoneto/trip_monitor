require "test_helper"

class ProcessUserRouteMetricsJobTest < ActiveJob::TestCase
  def setup
    @user = users(:one)
    @kitetrip_route = kitetrip_routes(:one)

    # Clean up any existing data
    UserRouteTrace.where(user: @user, kitetrip_route: @kitetrip_route).destroy_all
    UserRouteResume.where(user: @user, kitetrip_route: @kitetrip_route).destroy_all
  end

  test "should process route metrics successfully" do
    # Create some trace data (simulating a route with movement)
    base_time = Time.current
    create_trace_data([
      { lat: -3.7319, lng: -38.5434, time: base_time },           # Start
      { lat: -3.7350, lng: -38.5400, time: base_time + 60 },     # 1 minute later
      { lat: -3.7380, lng: -38.5380, time: base_time + 120 }     # 2 minutes later
    ])

    # Perform the job
    ProcessUserRouteMetricsJob.perform_now(@user.id, @kitetrip_route.id)

    # Check that a resume was created
    resume = UserRouteResume.find_by(user: @user, kitetrip_route: @kitetrip_route)
    assert_not_nil resume

    # Check that metrics were calculated
    assert resume.average_speed > 0
    assert resume.max_speed > 0
    assert resume.total_distance > 0
    assert resume.total_time > 0

    # Check that the executed route was set
    assert_not_nil resume.executed_route
    assert_equal 3, resume.points_count
  end

  test "should update existing resume when called again" do
    # Create initial trace data
    base_time = Time.current
    create_trace_data([
      { lat: -3.7319, lng: -38.5434, time: base_time },
      { lat: -3.7350, lng: -38.5400, time: base_time + 60 }
    ])

    # First execution
    ProcessUserRouteMetricsJob.perform_now(@user.id, @kitetrip_route.id)
    first_resume = UserRouteResume.find_by(user: @user, kitetrip_route: @kitetrip_route)
    first_distance = first_resume.total_distance

    # Add more trace data
    UserRouteTrace.create!(
      user: @user,
      kitetrip_route: @kitetrip_route,
      latitude: -3.7380,
      longitude: -38.5380,
      created_at: base_time + 120
    )

    # Second execution should update the same resume
    ProcessUserRouteMetricsJob.perform_now(@user.id, @kitetrip_route.id)

    # Should still have only one resume
    assert_equal 1, UserRouteResume.where(user: @user, kitetrip_route: @kitetrip_route).count

    # But with updated metrics
    updated_resume = UserRouteResume.find_by(user: @user, kitetrip_route: @kitetrip_route)
    assert updated_resume.total_distance > first_distance
    assert_equal 3, updated_resume.points_count
  end

  test "should handle no trace data gracefully" do
    # No trace data exists
    ProcessUserRouteMetricsJob.perform_now(@user.id, @kitetrip_route.id)

    # Should not create a resume when no data exists
    resume = UserRouteResume.find_by(user: @user, kitetrip_route: @kitetrip_route)
    assert_nil resume
  end

  test "should handle single trace point gracefully" do
    # Create only one trace point
    UserRouteTrace.create!(
      user: @user,
      kitetrip_route: @kitetrip_route,
      latitude: -3.7319,
      longitude: -38.5434
    )

    ProcessUserRouteMetricsJob.perform_now(@user.id, @kitetrip_route.id)

    resume = UserRouteResume.find_by(user: @user, kitetrip_route: @kitetrip_route)
    assert_not_nil resume

    # Should have default metrics for single point
    assert_equal 0.0, resume.average_speed
    assert_equal 0.0, resume.max_speed
    assert_equal 0.0, resume.total_distance
    assert_equal 0, resume.total_time
  end

  test "should calculate correct metrics for known route" do
    # Create a precise route with known distances and times
    base_time = Time.current

    # Route from Fortaleza center to nearby point (approximately 4km)
    create_trace_data([
      { lat: -3.7319, lng: -38.5434, time: base_time },           # Start: Fortaleza center
      { lat: -3.7500, lng: -38.5200, time: base_time + 600 }     # End: 10 minutes later
    ])

    ProcessUserRouteMetricsJob.perform_now(@user.id, @kitetrip_route.id)

    resume = UserRouteResume.find_by(user: @user, kitetrip_route: @kitetrip_route)
    assert_not_nil resume

    # Check time calculation (10 minutes = 600 seconds)
    assert_equal 600, resume.total_time

    # Distance should be approximately 4km (allowing for some variance in calculation)
    assert resume.total_distance > 3.0
    assert resume.total_distance < 5.0

    # Speed should be reasonable (distance/time * 3600 for km/h)
    expected_speed_kmh = (resume.total_distance / 600.0) * 3600.0
    assert_in_delta expected_speed_kmh, resume.average_speed, 0.1
    assert_in_delta expected_speed_kmh, resume.max_speed, 0.1
  end

  test "should filter out unrealistic speeds" do
    # Create trace data with unrealistic speed (teleportation)
    base_time = Time.current
    create_trace_data([
      { lat: -3.7319, lng: -38.5434, time: base_time },           # Start: Fortaleza
      { lat: -3.1319, lng: -38.0434, time: base_time + 1 }       # End: Very far away, 1 second later
    ])

    ProcessUserRouteMetricsJob.perform_now(@user.id, @kitetrip_route.id)

    resume = UserRouteResume.find_by(user: @user, kitetrip_route: @kitetrip_route)
    assert_not_nil resume

    # Should have filtered out the unrealistic speed
    assert_equal 0.0, resume.average_speed
    assert_equal 0.0, resume.max_speed
  end

  test "should raise error for invalid user" do
    assert_raises(ActiveRecord::RecordNotFound) do
      ProcessUserRouteMetricsJob.perform_now(999999, @kitetrip_route.id)
    end
  end

  test "should raise error for invalid kitetrip_route" do
    assert_raises(ActiveRecord::RecordNotFound) do
      ProcessUserRouteMetricsJob.perform_now(@user.id, 999999)
    end
  end

  private

  def create_trace_data(points)
    points.each do |point|
      UserRouteTrace.create!(
        user: @user,
        kitetrip_route: @kitetrip_route,
        latitude: point[:lat],
        longitude: point[:lng],
        created_at: point[:time]
      )
    end
  end
end