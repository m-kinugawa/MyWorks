require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:hoge)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    assert_select 'input[type="file"]'

    # invalid post
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: ""}}
    end
    assert_select 'div#error_explanation'

    # valid post
    content = "This micropost really ties the room together"
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: {micropost: {content: content, picture: picture}}
    end
    assert assigns(:micropost).picture?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    # delete post
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    # access other user's profile(to check no 'delete' link)
    get user_path(users(:fuga))
    assert_select 'a', text: 'delete', count: 0
  end

  test "micropost sidebar count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    # user who hasn't posted any micropost
    other_user = users(:hogera)
    log_in_as(other_user)
    get root_path
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 micropost", response.body
  end

  test "reply to other user" do
    log_in_as(@user)
    get root_path

    # invalid post(ID doesn't exist)
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@1000000000000000000"}}
    end
    assert_select 'div#error_explanation'
    # invalid post(Reply to yourself)
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@#{@user.id}-Hoge-Hoge"}}
    end
    assert_select 'div#error_explanation'
    # invalid post(ID doesn't match its user name)
    other_user = users(:fuga)
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: {micropost: {content: "@#{other_user.id}-Hogera-Hogera"}}
    end
    assert_select 'div#error_explanation'

    # valid post
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: {micropost: {content: "@#{other_user.id}-Fuga-Fuga"}}
    end
  end

  test "reply post visibility" do
    log_in_as(@user)
    get root_path
    reply_to_user = users(:fuga)
    content = "@#{reply_to_user.id}-Fuga-Fuga"
    post microposts_path, params: {micropost: {content: content}}
    follow_redirect!
    assert_match content, response.body

    # should be visible
    log_in_as(reply_to_user)
    get root_path
    assert_match content, response.body

    # shouldn't be visible
    other_user = users(:piyo)
    log_in_as(other_user)
    get root_path
    assert_no_match content, response.body
  end
end
