require "test_helper"

class UserRouteResumeTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @kitetrip = kitetrips(:one)
    @kitetrip_route = kitetrip_routes(:one)

    @valid_attributes = {
      user: @user,
      kitetrip_route: @kitetrip_route,
      average_speed: 25.5,
      max_speed: 45.2,
      total_distance: 12.345,
      total_time: 3600
    }

    @coordinates = [
      [-38.5434, -3.7319],  # Fortaleza, CE
      [-38.5400, -3.7350],  # Próximo ponto
      [-38.5380, -3.7380]   # Ponto final
    ]
  end

  test "should be valid with valid attributes" do
    resume = UserRouteResume.new(@valid_attributes)
    assert resume.valid?
  end

  test "should require user" do
    resume = UserRouteResume.new(@valid_attributes.except(:user))
    assert_not resume.valid?
    assert_includes resume.errors[:user], "must exist"
  end

  test "should require kitetrip_route" do
    resume = UserRouteResume.new(@valid_attributes.except(:kitetrip_route))
    assert_not resume.valid?
    assert_includes resume.errors[:kitetrip_route], "must exist"
  end

  test "should require average_speed" do
    resume = UserRouteResume.new(@valid_attributes.except(:average_speed))
    assert_not resume.valid?
    assert_includes resume.errors[:average_speed], "can't be blank"
  end

  test "should require max_speed" do
    resume = UserRouteResume.new(@valid_attributes.except(:max_speed))
    assert_not resume.valid?
    assert_includes resume.errors[:max_speed], "can't be blank"
  end

  test "should require total_distance" do
    resume = UserRouteResume.new(@valid_attributes.except(:total_distance))
    assert_not resume.valid?
    assert_includes resume.errors[:total_distance], "can't be blank"
  end

  test "should require total_time" do
    resume = UserRouteResume.new(@valid_attributes.except(:total_time))
    assert_not resume.valid?
    assert_includes resume.errors[:total_time], "can't be blank"
  end

  test "should not allow negative average_speed" do
    resume = UserRouteResume.new(@valid_attributes.merge(average_speed: -1))
    assert_not resume.valid?
    assert_includes resume.errors[:average_speed], "must be greater than or equal to 0"
  end

  test "should not allow negative max_speed" do
    resume = UserRouteResume.new(@valid_attributes.merge(max_speed: -1))
    assert_not resume.valid?
    assert_includes resume.errors[:max_speed], "must be greater than or equal to 0"
  end

  test "should not allow negative total_distance" do
    resume = UserRouteResume.new(@valid_attributes.merge(total_distance: -1))
    assert_not resume.valid?
    assert_includes resume.errors[:total_distance], "must be greater than or equal to 0"
  end

  test "should not allow negative total_time" do
    resume = UserRouteResume.new(@valid_attributes.merge(total_time: -1))
    assert_not resume.valid?
    assert_includes resume.errors[:total_time], "must be greater than or equal to 0"
  end

  test "should allow zero values for metrics" do
    resume = UserRouteResume.new(@valid_attributes.merge(
      average_speed: 0,
      max_speed: 0,
      total_distance: 0,
      total_time: 0
    ))
    assert resume.valid?
  end

  test "should set and get executed route coordinates" do
    resume = UserRouteResume.new(@valid_attributes)
    resume.executed_route_coordinates = @coordinates

    assert_equal @coordinates, resume.executed_route_coordinates
    assert_not_nil resume.executed_route
    assert_equal 3, resume.points_count
  end

  test "should return empty array when no executed route" do
    resume = UserRouteResume.new(@valid_attributes)
    assert_equal [], resume.executed_route_coordinates
    assert_equal [], resume.executed_route_points
    assert_equal 0, resume.points_count
  end

  test "should handle invalid coordinates gracefully" do
    resume = UserRouteResume.new(@valid_attributes)

    # Invalid: not an array
    resume.executed_route_coordinates = "invalid"
    assert_nil resume.executed_route

    # Invalid: less than 2 points
    resume.executed_route_coordinates = [[-38.5434, -3.7319]]
    assert_nil resume.executed_route

    # Invalid: malformed coordinates
    resume.executed_route_coordinates = [[-38.5434], [-3.7319]]
    assert_nil resume.executed_route
  end

  test "should calculate bounds for executed route" do
    resume = UserRouteResume.new(@valid_attributes)
    resume.executed_route_coordinates = @coordinates

    bounds = resume.bounds
    assert_not_nil bounds
    assert_equal [-38.5434, -3.7380], bounds[:southwest]
    assert_equal [-38.5380, -3.7319], bounds[:northeast]
  end

  test "should return nil bounds when no executed route" do
    resume = UserRouteResume.new(@valid_attributes)
    assert_nil resume.bounds
  end

  test "should handle JSON coordinates" do
    resume = UserRouteResume.new(@valid_attributes)
    json_coords = @coordinates.to_json

    resume.executed_route_coordinates_json = json_coords
    assert_equal @coordinates, resume.executed_route_coordinates
    assert_equal json_coords, resume.executed_route_coordinates_json
  end

  test "should handle invalid JSON gracefully" do
    resume = UserRouteResume.new(@valid_attributes)
    resume.executed_route_coordinates_json = "invalid json"

    # Should not raise error and should not set coordinates
    assert_nil resume.executed_route
  end

  test "should format speeds correctly" do
    resume = UserRouteResume.new(@valid_attributes)
    assert_equal "25.5 km/h", resume.formatted_average_speed
    assert_equal "45.2 km/h", resume.formatted_max_speed
  end

  test "should format distance correctly" do
    resume = UserRouteResume.new(@valid_attributes)
    assert_equal "12.345 km", resume.formatted_total_distance
  end

  test "should format time correctly" do
    # Test hours and minutes
    resume = UserRouteResume.new(@valid_attributes.merge(total_time: 3661)) # 1h 1m 1s
    assert_equal "1h 1m", resume.formatted_total_time

    # Test only minutes and seconds
    resume = UserRouteResume.new(@valid_attributes.merge(total_time: 61)) # 1m 1s
    assert_equal "1m 1s", resume.formatted_total_time

    # Test only seconds
    resume = UserRouteResume.new(@valid_attributes.merge(total_time: 30)) # 30s
    assert_equal "30s", resume.formatted_total_time

    # Test exact hour
    resume = UserRouteResume.new(@valid_attributes.merge(total_time: 3600)) # 1h
    assert_equal "1h 0m", resume.formatted_total_time
  end

  test "should provide scopes" do
    resume1 = UserRouteResume.create!(@valid_attributes)
    resume2 = UserRouteResume.create!(@valid_attributes.merge(average_speed: 30.0))

    # Test by_user scope
    user_resumes = UserRouteResume.by_user(@user)
    assert_includes user_resumes, resume1
    assert_includes user_resumes, resume2

    # Test by_route scope
    route_resumes = UserRouteResume.by_route(@kitetrip_route)
    assert_includes route_resumes, resume1
    assert_includes route_resumes, resume2

    # Test fastest_average scope
    fastest = UserRouteResume.fastest_average.first
    assert_equal resume2, fastest

    # Test longest_distance scope
    longest = UserRouteResume.longest_distance.first
    assert_equal resume1, longest # Both have same distance, so first created
  end

  test "should belong to user and kitetrip_route" do
    resume = UserRouteResume.new(@valid_attributes)
    assert_equal @user, resume.user
    assert_equal @kitetrip_route, resume.kitetrip_route
  end
end