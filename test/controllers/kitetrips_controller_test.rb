require "test_helper"

class KitetripsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kitetrip = kitetrips(:one)
    @user = @kitetrip.company.user
    sign_in @user
  end

  test "should get index" do
    get kitetrips_url
    assert_response :success
  end

  test "should get new" do
    get new_kitetrip_url
    assert_response :success
  end

  test "should create kitetrip" do
    assert_difference("Kitetrip.count") do
      post kitetrips_url, params: { kitetrip: { end_date: @kitetrip.end_date, name: @kitetrip.name, start_date: @kitetrip.start_date } }
    end

    assert_redirected_to kitetrip_url(Kitetrip.last)
  end

  test "should show kitetrip" do
    get kitetrip_url(@kitetrip)
    assert_response :success
  end

  test "should get edit" do
    get edit_kitetrip_url(@kitetrip)
    assert_response :success
  end

  test "should update kitetrip" do
    patch kitetrip_url(@kitetrip), params: { kitetrip: { end_date: @kitetrip.end_date, name: @kitetrip.name, start_date: @kitetrip.start_date } }
    assert_redirected_to kitetrip_url(@kitetrip)
  end

  test "should destroy kitetrip" do
    assert_difference("Kitetrip.count", -1) do
      delete kitetrip_url(@kitetrip)
    end

    assert_redirected_to kitetrips_url
  end
end
