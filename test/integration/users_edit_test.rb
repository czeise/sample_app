require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test 'unsuccesful edit' do
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
end
