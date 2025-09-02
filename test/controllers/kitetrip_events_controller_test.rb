require "test_helper"

class KitetripEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kitetrip_event = kitetrip_events(:one)
    @kitetrip = @kitetrip_event.kitetrip
    @user = @kitetrip.company.user
    sign_in @user
  end

  test "should get index" do
    get kitetrip_kitetrip_events_url(@kitetrip)
    assert_response :success
  end

  test "should get new" do
    get new_kitetrip_kitetrip_event_url(@kitetrip)
    assert_response :success
  end

  test "should create kitetrip_event" do
    assert_difference("KitetripEvent.count") do
      post kitetrip_kitetrip_events_url(@kitetrip), params: { kitetrip_event: { description: @kitetrip_event.description, event_date: @kitetrip_event.event_date, title: @kitetrip_event.title } }
    end

    assert_redirected_to kitetrip_kitetrip_event_url(@kitetrip, KitetripEvent.last)
  end

  test "should show kitetrip_event" do
    get kitetrip_kitetrip_event_url(@kitetrip, @kitetrip_event)
    assert_response :success
  end

  test "should get edit" do
    get edit_kitetrip_kitetrip_event_url(@kitetrip, @kitetrip_event)
    assert_response :success
  end

  test "should update kitetrip_event" do
    patch kitetrip_kitetrip_event_url(@kitetrip, @kitetrip_event), params: { kitetrip_event: { description: @kitetrip_event.description, event_date: @kitetrip_event.event_date, title: @kitetrip_event.title } }
    assert_redirected_to kitetrip_kitetrip_event_url(@kitetrip, @kitetrip_event)
  end

  test "should destroy kitetrip_event" do
    assert_difference("KitetripEvent.count", -1) do
      delete kitetrip_kitetrip_event_url(@kitetrip, @kitetrip_event)
    end

    assert_redirected_to kitetrip_kitetrip_events_url(@kitetrip)
  end
end
