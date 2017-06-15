require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
    @other_user = users(:two)
  end

  test 'should redirect index when not logged in' do
    get(users_path)
    assert_not(flash.empty?)
    assert_redirected_to(login_url)
  end

  test "should get signup" do
    get(signup_path)
    assert_response :success
  end

  test 'should redirect edit when not logged in' do
    get(edit_user_path(@user))
    assert_not(flash.empty?)
    assert_redirected_to(login_url)
  end

  test 'should redirect update when not logged in' do
    patch(user_path(@user), params: { user: { name: 'New Name',
                                              email: 'new@example.com' } })
    assert_not(flash.empty?)
    assert_redirected_to(login_url)
  end

  test 'should redirect edit when logged in as wrong user' do
    log_in_as(@other_user)
    get(edit_user_path(@user))
    assert(flash.empty?)
    assert_redirected_to(root_url)
  end

  test 'should redirect update when logged in as wrong user' do
    log_in_as(@other_user)
    patch(user_path(@user), params: { user: { name: 'New Name',
                                              email: 'new@example.com' } })
    assert(flash.empty?)
    assert_redirected_to(root_url)
  end

  test 'admin attribute should not be editable through the web' do
    log_in_as(@other_user)
    assert_not(@other_user.admin?)
    patch(user_path(@other_user),
          params: { user: { password: 'password',
                            password_confirmation: 'password', admin: true } })
    assert_not(@other_user.reload.admin?)
  end

  test 'should redirect destroy when not logged in' do
    assert_no_difference 'User.count' do
      delete(user_path(@user))
    end
    assert_redirected_to(login_url)
  end

  test 'should redirect destroy when logged in as non-admin' do
    log_in_as(@user)
    assert_no_difference 'User.count' do
      delete(user_path(@user))
    end
    assert_redirected_to(root_url)
  end

  test 'should redirect following when not logged in' do
    get(following_user_path(@user))
    assert_redirected_to(login_url)
  end

  test 'should redirect followers when not logged in' do
    get(followers_user_path(@user))
    assert_redirected_to(login_url)
  end
end
