require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test 'unsuccesful edit' do
    log_in_as(@user)
    get(edit_user_path(@user))
    assert_template('users/edit')
    patch(user_path(@user), params: { user: { name: '', email: 'foo@invalid',
                                              password: 'foo',
                                              password_confirmation: 'bar' } })

    assert_template('users/edit')
    assert_select('div.alert', 'The form contains 4 errors.')
  end

  test 'successful edit' do
    new_name = 'Foo Bar'
    new_email = 'foo@bar.com'

    log_in_as(@user)

    get(edit_user_path(@user))
    assert_template('users/edit')
    patch(user_path(@user), params: { user: { name: new_name,
                                              email: new_email,
                                              password: '',
                                              password_confirmation: '' } })

    assert_not(flash.empty?) # Better to check for the successful flash message?
    assert_redirected_to(@user)

    # Must reload the user to get the updates
    @user.reload
    assert_equal(new_name, @user.name)
    assert_equal(new_email, @user.email)
  end

  test 'friendly forward to edit page' do
    get(edit_user_path(@user))

    # The logged_in_user before action of the users controller should save the
    # forwarding url if a user isn't logged in
    assert_not_nil(session[:forwarding_url])

    log_in_as(@user)

    # The url should be deleted after the user logs in and is forwarded
    assert_nil(session[:forwarding_url])

    assert_redirected_to(edit_user_path(@user))
  end
end
