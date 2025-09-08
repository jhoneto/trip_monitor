require "application_system_test_case"

class KitetripsTest < ApplicationSystemTestCase
  setup do
    @kitetrip = kitetrips(:one)
  end

  test "visiting the index" do
    visit kitetrips_url
    assert_selector "h1", text: "Kitetrips"
  end

  test "should create kitetrip" do
    visit kitetrips_url
    click_on "New kitetrip"

    fill_in "End date", with: @kitetrip.end_date
    fill_in "Name", with: @kitetrip.name
    fill_in "Start date", with: @kitetrip.start_date
    click_on "Create Kitetrip"

    assert_text "Kitetrip was successfully created"
    click_on "Back"
  end

  test "should update Kitetrip" do
    visit kitetrip_url(@kitetrip)
    click_on "Edit this kitetrip", match: :first

    fill_in "End date", with: @kitetrip.end_date.to_s
    fill_in "Name", with: @kitetrip.name
    fill_in "Start date", with: @kitetrip.start_date.to_s
    click_on "Update Kitetrip"

    assert_text "Kitetrip was successfully updated"
    click_on "Back"
  end

  test "should destroy Kitetrip" do
    visit kitetrip_url(@kitetrip)
    accept_confirm { click_on "Destroy this kitetrip", match: :first }

    assert_text "Kitetrip was successfully destroyed"
  end
end
