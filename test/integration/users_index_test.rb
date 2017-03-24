require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test 'index including pagination' do
    log_in_as(@user)
    get(users_path)
    assert_template('users/index')
    assert_select('div.pagination', count: 2)
    User.paginate(page: 1).each do |user|
      puts "user.id: #{user.id}"
      assert_select('a[href=?]', user_path(user), text: user.name)
    end
  end
end
