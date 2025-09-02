require "test_helper"

class KitetripEventsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kitetrip_event = kitetrip_events(:one)
  end

  test "should get index" do
    get kitetrip_events_url
    assert_response :success
  end

  test "should get new" do
    get new_kitetrip_event_url
    assert_response :success
  end

  test "should create kitetrip_event" do
    assert_difference("KitetripEvent.count") do
      post kitetrip_events_url, params: { kitetrip_event: { description: @kitetrip_event.description, event_date: @kitetrip_event.event_date, kitetrip_id: @kitetrip_event.kitetrip_id, title: @kitetrip_event.title } }
    end

    assert_redirected_to kitetrip_event_url(KitetripEvent.last)
  end

  test "should show kitetrip_event" do
    get kitetrip_event_url(@kitetrip_event)
    assert_response :success
  end

  test "should get edit" do
    get edit_kitetrip_event_url(@kitetrip_event)
    assert_response :success
  end

  test "should update kitetrip_event" do
    patch kitetrip_event_url(@kitetrip_event), params: { kitetrip_event: { description: @kitetrip_event.description, event_date: @kitetrip_event.event_date, kitetrip_id: @kitetrip_event.kitetrip_id, title: @kitetrip_event.title } }
    assert_redirected_to kitetrip_event_url(@kitetrip_event)
  end

  test "should destroy kitetrip_event" do
    assert_difference("KitetripEvent.count", -1) do
      delete kitetrip_event_url(@kitetrip_event)
    end

    assert_redirected_to kitetrip_events_url
  end
end
