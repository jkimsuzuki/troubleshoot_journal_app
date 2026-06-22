require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  test "new" do
    get new_password_url
    assert_response :success
  end

  test "create" do
    assert_enqueued_emails 1 do
      post passwords_url, params: { email_address: users(:one).email_address }
    end

    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "create for an unknown user redirects but sends no mail" do
    assert_no_enqueued_emails do
      post passwords_url, params: { email_address: "unknown@example.com" }
    end

    assert_redirected_to new_session_path
    assert_equal "Password reset instructions sent (if user with that email address exists).", flash[:notice]
  end

  test "edit" do
    user = users(:one)

    get edit_password_url(user.password_reset_token)

    assert_response :success
  end

  test "update" do
    user = users(:one)
    token = user.password_reset_token

    patch password_url(token), params: {
      password: "new-password-123",
      password_confirmation: "new-password-123"
    }

    assert_redirected_to new_session_path
    assert_equal "Password has been reset.", flash[:notice]
  end

  test "update with invalid token redirects" do
    get edit_password_url("invalid-token")

    assert_redirected_to new_password_path
    assert_equal "Password reset link is invalid or has expired.", flash[:alert]
  end
end
