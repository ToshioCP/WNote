require 'test_helper'

class LoginsControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'form' do
        assert_select 'label', 'Email'
        assert_select 'input.form-control'
        assert_select 'label', 'password'
        assert_select 'input.form-control'
      end
    end 
  end

  test "should get create" do
    post :create, params: {email: 'lxboyjp@gmail.com', password: 'aabbccddeeffgg'}
    assert_redirected_to controller: :users, action: :show
    assert_equal users(:toshiocp).id, session[:current_user_id]
    assert_equal "You have successfully logged in.", flash[:success]
  end

  test "should get destroy" do
    get :destroy
    assert_redirected_to root_path
    assert_nil session[:current_user_id]
    assert_equal "You have successfully logged out.", flash[:success]
  end

end
