require "application_system_test_case"

class KitetripParticipantsTest < ApplicationSystemTestCase
  setup do
    @kitetrip_participant = kitetrip_participants(:one)
  end

  test "visiting the index" do
    visit kitetrip_participants_url
    assert_selector "h1", text: "Kitetrip participants"
  end

  test "should create kitetrip participant" do
    visit kitetrip_participants_url
    click_on "New kitetrip participant"

    fill_in "Kitetrip", with: @kitetrip_participant.kitetrip_id
    fill_in "Role", with: @kitetrip_participant.role
    fill_in "User", with: @kitetrip_participant.user_id
    click_on "Create Kitetrip participant"

    assert_text "Kitetrip participant was successfully created"
    click_on "Back"
  end

  test "should update Kitetrip participant" do
    visit kitetrip_participant_url(@kitetrip_participant)
    click_on "Edit this kitetrip participant", match: :first

    fill_in "Kitetrip", with: @kitetrip_participant.kitetrip_id
    fill_in "Role", with: @kitetrip_participant.role
    fill_in "User", with: @kitetrip_participant.user_id
    click_on "Update Kitetrip participant"

    assert_text "Kitetrip participant was successfully updated"
    click_on "Back"
  end

  test "should destroy Kitetrip participant" do
    visit kitetrip_participant_url(@kitetrip_participant)
    accept_confirm { click_on "Destroy this kitetrip participant", match: :first }

    assert_text "Kitetrip participant was successfully destroyed"
  end
end
