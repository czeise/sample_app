require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test 'invalid signup information' do
    get signup_path

    assert_no_difference "User.count" do
      post(signup_path, params: { user: { name: '', email: 'user@invalid',
                                          password: 'foo',
                                          password_confirmation: 'bar' } })
    end

    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select 'form[action="/signup"]'
  end

  test 'valid signup information with account activation' do
    get signup_path
    assert_difference 'User.count', 1 do
      post(users_path, params: { user: { name: 'Example User',
                                         email: 'user@example.com',
                                         password: 'password',
                                         password_confirmation: 'password' } })
    end

    # Activation email should be sent
    assert_equal(1, ActionMailer::Base.deliveries.size)

    # User shouldn't be activated yet
    user = assigns(:user)
    assert_not(user.activated?)

    # After signup, should be redirected to home page with email message
    follow_redirect!
    assert_template 'static_pages/home'
    assert_not flash.nil?
    assert_select(
      'div.alert.alert-info',
      'Please check your email to activate your account.'
    )
    assert_not(logged_in?)

    # Try to log in before activation
    log_in_as(user)
    assert_not(logged_in?)

    # Invalid activation token in link
    get(edit_account_activation_path('invalid token', email: user.email))
    assert_not(logged_in?)

    # Invalid email in link
    get(edit_account_activation_path(user.activation_token, email: 'wrong'))
    assert_not(logged_in?)

    # Valid email link
    get(edit_account_activation_path(user.activation_token, email: user.email))
    assert(user.reload.activated?)
    follow_redirect!
    assert_template('users/show')
    assert(logged_in?)
  end
end
