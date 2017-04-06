require 'test_helper'

class UserShowTest < ActionDispatch::IntegrationTest
  def setup
    @inactive = users(:inactive)
    @active = users(:one)
  end

  test 'inactive user show page redirects to home' do
    get(user_path(@inactive))
    assert_redirected_to(root_url)
  end

  test 'active user show page should be displayed' do
    get(user_path(@active))
    assert_template('users/show')
    assert_response(:success)
  end
end
