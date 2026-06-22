require "test_helper"

class TagsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @tag = tags(:one)

    sign_in_as @user
  end

  test "should get index" do
    get tags_url
    assert_response :success
  end

  test "should get show" do
    get tag_url(@tag)
    assert_response :success
  end
end
