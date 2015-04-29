require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  setup do
    @user = users(:toshiocp)
    @request.headers["HTTP_REFERER"] = root_url
  end

  test "should show user" do
    get :show, nil, {'current_user_id' => @user.id}
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
    get :new
    assert_response :success
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
    end
    assert_select 'div.wnote-main' do
      assert_select 'h1','Sign Up'
      assert_select 'form' do
        assert_select 'input.form-control',5
        assert_select 'input.btn'
        assert_select 'input.btn-primary'
      end
    end
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: user_param('Mayu','Mayu@sekiya.jp','mayuchan')
    end
    assert_redirected_to action: :show
    assert_equal 'Welcome to WNote !!', flash[:success]
  end

  test "should get edit" do
    get :edit, nil, {'current_user_id' => @user.id}
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'form' do
        assert_select "input[type='hidden'][value='patch']"
        assert_select 'h2', 'Authentication'
# when using regexp
        assert_select "input.form-control:match('name', ?)", /current_password/
# ? is the sign of the substitution
        assert_select "input.form-control[name=?]", 'current_password'
# You don't need to use substitution anyway.
# It's also OK to write like this.
        assert_select "input.form-control[name=current_password]"
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
    parameter = {current_password: 'aabbccddeeffgg', user: user_param('Mayu', 'mayu@sekiya.jp', 'mayuchan')}
    patch :update, parameter, {'current_user_id' => @user.id}
    assert_redirected_to '/users'
    assert_equal 'User was successfully updated.', flash[:success]
    @user = User.find(@user.id) # reload
    assert_not_equal 'ToshioCP', @user.name, "Name wasn't updated."
    assert_equal 'mayu@sekiya.jp', @user.email, "Email wasn't updated."
    assert @user.authenticate('mayuchan'), "Password wasn't updated."
  end

  test "before destroy user" do
    delete :destroy, nil, {'current_user_id' => @user.id}
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'form' do
        assert_select 'h2', 'Authentication is needed.'
        assert_select "input.form-control[name=?]", 'user[password]'
        assert_select "input[class='btn btn-primary']"
      end
    end
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      post :destroy, {user: {password: 'aabbccddeeffgg'}}, {'current_user_id' => @user.id}
    end
    assert_redirected_to root_url
    assert_equal 'User was successfully destroyed.', flash[:success]
  end

  private
    def user_param(name, email, password)
      {name: name, email: email, email_confirmation: email, password: password, password_confirmation: password}
    end
end
