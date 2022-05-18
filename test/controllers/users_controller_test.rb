require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = users(:toshiocp)
  end

  test "should show user" do
    login
    get user_path
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
    end
    assert_select 'div.wnote-main' do
      assert_select 'h1' do
        assert_select 'span', @user.name
        assert_select 'a.btn', 'Edit'
        assert_select 'a.btn-primary'
      end
    end
  end

  test "should get new" do
    get new_user_path
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
    end
    assert_select 'div.wnote-main' do
      assert_select 'h1','Sign up'
      assert_select 'form' do
        assert_select 'input.form-control',5
        assert_select 'input.btn'
        assert_select 'input.btn-primary'
      end
    end
  end

  test "should create user" do
    assert_difference('User.count') do
      post user_path, params: {user: user_param('Mayu','Mayu@sekiya.jp','mayuchan')}
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Welcome to WNote !!', flash[:success]
  end

  test "should get edit" do
    login
    get edit_user_path
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'form' do
        assert_select "input[type='hidden'][value='patch']"
        assert_select 'h2', 'Authentication'
# when using regexp
        assert_select "input.form-control:match('name', ?)", /user\[current_password\]/
# ? is the sign of the substitution
        assert_select "input.form-control[name=?]", 'user[current_password]'
# You don't need to use substitution anyway.
# It's also OK to write like this.
        assert_select "input.form-control[name='user[current_password]']"
# Those three above have the same meaning.
        assert_select 'h2', 'Edit your profile'
        assert_select "input.form-control[name=?]", 'user[name]'
        assert_select "input.form-control[name=?]", 'user[email]'
        assert_select "input.form-control[name=?]", 'user[email_confirmation]'
        assert_select "input.form-control[name=?]", 'user[password]'
        assert_select "input.form-control[name=?]", 'user[password_confirmation]'
        assert_select "input[class='btn btn-primary']"
      end
    end
  end

  test "should update user" do
    login
    parameter = {current_password: 'aabbccddeeffgg', user: user_param('Mayu', 'mayu@sekiya.jp', 'mayuchan')}
    patch user_path, params: parameter
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'User was successfully updated.', flash[:success]
    @user = User.find(@user.id) # reload
    assert_not_equal 'ToshioCP', @user.name, "Name wasn't updated."
    assert_equal 'mayu@sekiya.jp', @user.email, "Email wasn't updated."
    assert @user.authenticate('mayuchan'), "Password wasn't updated."
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      @user = users(:foobar)
      login_another_user
      delete user_path, params: {user: {password: 'hhiijjkkllmmnn'}}
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'User was successfully destroyed.', flash[:success]
  end

  test "should not destroy admin user" do
    assert_no_difference('User.count') do
      login
      delete user_path, params: {user: {password: 'aabbccddeeffgg'}}
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal "Can't delete admin.", flash[:warning]
  end

  test "should reset articles" do
    login
    get user_reset_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_empty @user.articles
  end

  private
    def user_param(name, email, password)
      {name: name, email: email, email_confirmation: email, password: password, password_confirmation: password}
    end
end
