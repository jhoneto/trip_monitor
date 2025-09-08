require "application_system_test_case"

class KitetripEventsTest < ApplicationSystemTestCase
  setup do
    @kitetrip_event = kitetrip_events(:one)
  end

  test "visiting the index" do
    visit kitetrip_events_url
    assert_selector "h1", text: "Kitetrip events"
  end

  test "should create kitetrip event" do
    visit kitetrip_events_url
    click_on "New kitetrip event"

    fill_in "Description", with: @kitetrip_event.description
    fill_in "Event date", with: @kitetrip_event.event_date
    fill_in "Kitetrip", with: @kitetrip_event.kitetrip_id
    fill_in "Title", with: @kitetrip_event.title
    click_on "Create Kitetrip event"

    assert_text "Kitetrip event was successfully created"
    click_on "Back"
  end

  test "should update Kitetrip event" do
    visit kitetrip_event_url(@kitetrip_event)
    click_on "Edit this kitetrip event", match: :first

    fill_in "Description", with: @kitetrip_event.description
    fill_in "Event date", with: @kitetrip_event.event_date.to_s
    fill_in "Kitetrip", with: @kitetrip_event.kitetrip_id
    fill_in "Title", with: @kitetrip_event.title
    click_on "Update Kitetrip event"

    assert_text "Kitetrip event was successfully updated"
    click_on "Back"
  end

  test "should destroy Kitetrip event" do
    visit kitetrip_event_url(@kitetrip_event)
    accept_confirm { click_on "Destroy this kitetrip event", match: :first }

    assert_text "Kitetrip event was successfully destroyed"
  end
end
