require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in_as @user
  end

  test "should get timeline" do
    get timeline_url
    assert_response :success
  end

  test "should get reports" do
    get reports_url
    assert_response :success
  end

  test "should get search" do
    get search_url
    assert_response :success
  end

  test "should get tags" do
    get tags_url
    assert_response :success
  end
end
