require "application_system_test_case"

class KitetripRoutesTest < ApplicationSystemTestCase
  setup do
    @kitetrip_route = kitetrip_routes(:one)
  end

  test "visiting the index" do
    visit kitetrip_routes_url
    assert_selector "h1", text: "Kitetrip routes"
  end

  test "should create kitetrip route" do
    visit kitetrip_routes_url
    click_on "New kitetrip route"

    fill_in "End date", with: @kitetrip_route.end_date
    fill_in "Kitetrip", with: @kitetrip_route.kitetrip_id
    fill_in "Start date", with: @kitetrip_route.start_date
    click_on "Create Kitetrip route"

    assert_text "Kitetrip route was successfully created"
    click_on "Back"
  end

  test "should update Kitetrip route" do
    visit kitetrip_route_url(@kitetrip_route)
    click_on "Edit this kitetrip route", match: :first

    fill_in "End date", with: @kitetrip_route.end_date.to_s
    fill_in "Kitetrip", with: @kitetrip_route.kitetrip_id
    fill_in "Start date", with: @kitetrip_route.start_date.to_s
    click_on "Update Kitetrip route"

    assert_text "Kitetrip route was successfully updated"
    click_on "Back"
  end

  test "should destroy Kitetrip route" do
    visit kitetrip_route_url(@kitetrip_route)
    accept_confirm { click_on "Destroy this kitetrip route", match: :first }

    assert_text "Kitetrip route was successfully destroyed"
  end
end
