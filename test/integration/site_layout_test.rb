require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test 'layout links without being logged in' do
    get(root_path)
    assert_template('static_pages/home')
    assert_select('a[href=?]', root_path, count: 2)
    assert_select('a[href=?]', help_path)
    assert_select('a[href=?]', about_path)
    assert_select('a[href=?]', contact_path)
    assert_select('a[href=?]', login_path)

    # Can't access logged in links before logging in...
    user = users(:one)
    assert_select('a[href=?]', users_path, count: 0)
    assert_select('a[href=?]', user_path(user), count: 0)
    assert_select('a[href=?]', edit_user_path(user), count: 0)
    assert_select('a[href=?]', logout_path, count: 0)

    get contact_path
    assert_select('title', full_title('Contact'))
    get signup_path
    assert_select('title', full_title('Sign up'))
  end

  test 'layout links when logged in' do
    user = users(:one)
    log_in_as(user)
    get(root_path)
    assert_template('static_pages/home')
    assert_select('a[href=?]', root_path, count: 2)
    assert_select('a[href=?]', help_path)
    assert_select('a[href=?]', about_path)
    assert_select('a[href=?]', contact_path)

    # Added/removed links for logged in users
    assert_select('a[href=?]', login_path, count: 0)
    assert_select('a[href=?]', logout_path)
    assert_select('a[href=?]', users_path)
    assert_select('a[href=?]', user_path(user))
    assert_select('a[href=?]', edit_user_path(user))
  end
end
