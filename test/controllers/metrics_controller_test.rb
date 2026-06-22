require "test_helper"

class MetricsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get metrics_path
    assert_response :success
  end
end
