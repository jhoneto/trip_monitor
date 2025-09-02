require "test_helper"

class KitetripParticipantsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @kitetrip_participant = kitetrip_participants(:one)
  end

  test "should get index" do
    get kitetrip_participants_url
    assert_response :success
  end

  test "should get new" do
    get new_kitetrip_participant_url
    assert_response :success
  end

  test "should create kitetrip_participant" do
    assert_difference("KitetripParticipant.count") do
      post kitetrip_participants_url, params: { kitetrip_participant: { kitetrip_id: @kitetrip_participant.kitetrip_id, role: @kitetrip_participant.role, user_id: @kitetrip_participant.user_id } }
    end

    assert_redirected_to kitetrip_participant_url(KitetripParticipant.last)
  end

  test "should show kitetrip_participant" do
    get kitetrip_participant_url(@kitetrip_participant)
    assert_response :success
  end

  test "should get edit" do
    get edit_kitetrip_participant_url(@kitetrip_participant)
    assert_response :success
  end

  test "should update kitetrip_participant" do
    patch kitetrip_participant_url(@kitetrip_participant), params: { kitetrip_participant: { kitetrip_id: @kitetrip_participant.kitetrip_id, role: @kitetrip_participant.role, user_id: @kitetrip_participant.user_id } }
    assert_redirected_to kitetrip_participant_url(@kitetrip_participant)
  end

  test "should destroy kitetrip_participant" do
    assert_difference("KitetripParticipant.count", -1) do
      delete kitetrip_participant_url(@kitetrip_participant)
    end

    assert_redirected_to kitetrip_participants_url
  end
end
