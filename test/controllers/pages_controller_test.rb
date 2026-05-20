require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should get timeline" do
    get pages_timeline_url
    assert_response :success
  end

  test "should get reports" do
    get pages_reports_url
    assert_response :success
  end

  test "should get search" do
    get pages_search_url
    assert_response :success
  end

  test "should get tags" do
    get pages_tags_url
    assert_response :success
  end
end
