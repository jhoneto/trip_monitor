require "test_helper"

class UserRouteResumesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get user_route_resumes_show_url
    assert_response :success
  end
end
