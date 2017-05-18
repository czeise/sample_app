require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
  end

  test "micropost interface" do
    log_in_as(@user)
    get(root_path)
    assert_select('div.pagination')

    # Invalid submission
    assert_no_difference('Micropost.count') do
      post(microposts_path, params: { micropost: { content: '' } })
    end
    assert_select('div#error_explanation')

    # Valid submission
    content = 'Some content.'
    assert_difference('Micropost.count', 1) do
      post(microposts_path, params: { micropost: { content: content } })
    end
    assert_redirected_to(root_url)
    follow_redirect!
    assert_match(content, response.body)

    # Delete post
    assert_select('a', text: 'delete')
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference('Micropost.count', -1) do
      delete(micropost_path(first_micropost))
    end

    # Visit different user (no delete links)
    get(user_path(users(:two)))
    assert_select('a', text: 'delete', count: 0)
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get(root_path)
    assert_match('34 microposts', response.body)

    # User with zero microposts
    other_user = users(:user_4)
    log_in_as(other_user)
    get(root_path)
    assert_match('0 microposts', response.body)
    other_user.microposts.create!(content: 'A micropost')
    get(root_path)
    assert_match('1 micropost', response.body)
  end
end
