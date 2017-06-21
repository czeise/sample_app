require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @admin = users(:admin)
    @user_two = users(:two)
  end

  test 'index as admin including pagination and delete links' do
    # skip('need to handle deleting microposts with users (13.1.4)')
    log_in_as(@admin)

    # Setup an inactive user on the first page
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.first.toggle!(:activated)

    get(users_path)
    assert_template('users/index')
    assert_select('ul.pagination', count: 2)
    assigns(:users).each do |user|
      assert user.activated?
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
    # skip('need to handle deleting microposts with users (13.1.4)')
    log_in_as(@user)
    get(users_path)
    assert_template('users/index')
    assert_select('ul.pagination', count: 2)

    # Non-admins shouldn't see 'delete' links
    assert_select('a[href=?]', user_path(@user), text: 'delete', method: :delete, count: 0)

    # Non-admins can't delete users
    assert_no_difference 'User.count' do
      delete(user_path(@user_two))
    end
  end
end
