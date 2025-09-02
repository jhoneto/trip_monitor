require "test_helper"

class KitetripRoutesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kitetrip_route = kitetrip_routes(:one)
  end

  test "should get index" do
    get kitetrip_routes_url
    assert_response :success
  end

  test "should get new" do
    get new_kitetrip_route_url
    assert_response :success
  end

  test "should create kitetrip_route" do
    assert_difference("KitetripRoute.count") do
      post kitetrip_routes_url, params: { kitetrip_route: { end_date: @kitetrip_route.end_date, kitetrip_id: @kitetrip_route.kitetrip_id, start_date: @kitetrip_route.start_date } }
    end

    assert_redirected_to kitetrip_route_url(KitetripRoute.last)
  end

  test "should show kitetrip_route" do
    get kitetrip_route_url(@kitetrip_route)
    assert_response :success
  end

  test "should get edit" do
    get edit_kitetrip_route_url(@kitetrip_route)
    assert_response :success
  end

  test "should update kitetrip_route" do
    patch kitetrip_route_url(@kitetrip_route), params: { kitetrip_route: { end_date: @kitetrip_route.end_date, kitetrip_id: @kitetrip_route.kitetrip_id, start_date: @kitetrip_route.start_date } }
    assert_redirected_to kitetrip_route_url(@kitetrip_route)
  end

  test "should destroy kitetrip_route" do
    assert_difference("KitetripRoute.count", -1) do
      delete kitetrip_route_url(@kitetrip_route)
    end

    assert_redirected_to kitetrip_routes_url
  end
end
