require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:one)
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

end
