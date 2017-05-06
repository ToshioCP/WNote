require 'test_helper'

class AdminControllerTest < ActionController::TestCase

  setup do
    @admin = users(:toshiocp)
    @nonadmin = users(:foobar)
  end

  test "non admin" do
    get :list_users, session: {current_user_id: @nonadmin.id}
    assert_redirected_to root_path
    assert_equal "You don't have access to this section.", flash[:warnings]
    delete :delete_user, params: {id: @admin.id}, session: {current_user_id: @nonadmin.id}
    assert_redirected_to root_path
    assert_equal "You don't have access to this section.", flash[:warnings]
  end

  test "list users" do
    get :list_users, session: {current_user_id: @admin.id}
    assert_response :success
  end
  test "delete user" do
    delete :delete_user, params: {id: @nonadmin.id}, session: {current_user_id: @admin.id}
    assert_redirected_to root_path
    assert_equal "User was successfully destroyed.", flash[:success]
    assert_nil User.find_by(id: @nonadmin.id), "User was not deleted."
# admin can't delete (him/her)self
    delete :delete_user, params: {id: @admin.id}, session: {current_user_id: @admin.id}
    assert_redirected_to root_path
    assert_equal "User can't delete (him/her)self).", flash[:warnings]
    assert_not_nil User.find_by(id: @admin.id), "User was deleted."

  end

end
