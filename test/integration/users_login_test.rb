require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
  end

  test 'login with invalid information' do
    get(login_path)
    assert_template('sessions/new')
    post(login_path, params: { session: { email: '', password: '' } })
    assert_template('sessions/new')
    assert_not flash.empty?
    get(root_path)
    assert(flash.empty?)
  end

  test 'login with valid information followed by logout' do
    # Log in
    get(login_path)
    post(login_path, params: { session: { email: @user.email,
                                          password: 'password' } })
    assert(logged_in?)
    assert_redirected_to(@user)
    follow_redirect!
    assert_template('users/show')
    assert_select('a[href=?]', login_path, count: 0)
    assert_select('a[href=?]', logout_path)
    assert_select('a[href=?]', user_path(@user))

    # Log out
    delete(logout_path)
    assert_not(logged_in?)
    assert_redirected_to(root_url)

    # Log out again (user tries to logout of a stale instance after they've
    # already logged out)
    delete(logout_path)

    # State after logging out
    follow_redirect!
    assert_template('static_pages/home')
    assert_select('a[href=?]', login_path)
    assert_select('a[href=?]', logout_path, count: 0)
    assert_select('a[href=?]', user_path(@user), count: 0)
  end

  test 'login with remembering' do
    log_in_as(@user) # Method remembers by default

    # `assigns(:user)` accesses the `@user` variable of the sessions controller
    assert_equal(cookies['remember_token'], assigns(:user).remember_token)
  end

  test 'login without remembering' do
    log_in_as(@user) # Set a remember_me cookie with initial login
    log_in_as(@user, remember_me: '0') # Forget it!
    assert_empty cookies['remember_token'] # Can't use symbols in tests...
  end
end
