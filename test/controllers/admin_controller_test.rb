require 'test_helper'

class AdminControllerTest < ActionDispatch::IntegrationTest

  setup do
    @admin = users(:toshiocp)
    @nonadmin = users(:foobar)
  end

  test "non admin" do
    @user = @nonadmin
    login_another_user
    get admin_list_users_path
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal "You don't have access to this section.", flash[:warnings]

    delete "/admin/users/#{@admin.id}"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal "You don't have access to this section.", flash[:warnings]
  end

  test "admin lists users" do
    @user = @admin
    login
    get admin_list_users_path
    assert_response :success
  end

  test "admin deletes user" do
    @user = @admin
    login
    delete "/admin/users/#{@nonadmin.id}"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal "User was successfully destroyed.", flash[:success]
    assert_nil User.find_by(id: @nonadmin.id), "User was not deleted."
# admin can't delete (him/her)self
    delete "/admin/users/#{@admin.id}"
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal "Can't delete admin.", flash[:warnings]
    assert_not_nil User.find_by(id: @admin.id), "User was deleted."

  end

end
