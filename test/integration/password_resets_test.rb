require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template 'password_resets/new'

    # Invalid email
    assert_no_difference 'ActionMailer::Base.deliveries.size' do
      post password_resets_path, params: { password_reset: { email: "" } }
    end
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # Valid email
    assert_difference 'ActionMailer::Base.deliveries.size', 1 do
      post password_resets_path, params: { password_reset: { email: @user.email } }
    end
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to root_url

    # Password reset form
    user = assigns(:user)

    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)

    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # Invalid password & confirmation
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password:              "foobaz",
                                                                   password_confirmation: "barquux" }}
    assert_select "div#error_explanation"

    # Empty password
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                               user: { password:              "",
                                                                       password_confirmation: "" }}
        assert_select "div#error_explanation"

    # Valid password and confirmation
    patch password_reset_path(user.reset_token), params: { email: user.email,
                                                           user: { password:              "foobaz",
                                                                   password_confirmation: "foobaz" }}
    assert_nil user.reload.reset_digest
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)

    patch password_reset_path(@user.reset_token), params: { email: @user.email,
                                                           user: { password:              "foobaz",
                                                                   password_confirmation: "foobaz" }}
    assert_not flash.empty?
    assert_redirected_to new_password_reset_path
    follow_redirect!
    assert_match 'expired', response.body
  end

end
