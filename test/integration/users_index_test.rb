require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @admin = users(:admin)
    @user_two = users(:two)
  end

  test 'index as admin including pagination and delete links' do
    log_in_as(@admin)
    get(users_path)
    assert_template('users/index')
    assert_select('div.pagination', count: 2)
    User.paginate(page: 1).each do |user|
      assert_select('a[href=?]', user_path(user), text: user.name)
      unless user == @admin
        assert_select('a[href=?]', user_path(user), text: 'delete',
                                                    method: :delete)
      end
    end

    # Admin can delete users...
    assert_difference 'User.count', -1 do
      delete(user_path(@user))
    end
  end

  test 'index as non-admin' do
    log_in_as(@user)
    get(users_path)
    assert_template('users/index')
    assert_select('div.pagination', count: 2)

    User.paginate(page: 1).each do |user|
      assert_select('a[href=?]', user_path(user), text: user.name)

      # Non-admins shouldn't see 'delete' links
      assert_select('a[href=?]', user_path(user), text: 'delete',
                                                  method: :delete, count: 0)
    end

    # Non-admins can't delete users
    assert_no_difference 'User.count' do
      delete(user_path(@user_two))
    end
  end
end
