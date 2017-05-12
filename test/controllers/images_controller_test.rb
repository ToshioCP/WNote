require 'test_helper'

# Rails5 から、Functional Test の親クラスが変わっていることに注意
# ActionController::TestCase => ActionDispatch::IntegrationTest
# 参考 => http://qiita.com/soutaro/items/b990dc9b0f9e46b0f4c2
# そのため、テストの書き方、例えばgetの書き方も違ってくる
# get :index はダメ => get note_images_url はOK

class ImagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @image = images(:one)
    @note = @image.note
    @section = @note.section
    @article = @section.article
    @user = @article.user
  end

  test "owner should get index" do
# Guest can not access to index
    get note_images_url(@note)
    assert_response :redirect
    follow_redirect!
    assert_response :success
# Login
    login
# Owner can access to index
    get note_images_url(@note)
    assert_response :success
    assert_select 'td'
    assert_select 'td', @image.name
  end

  test "owner should get new and create image" do
    login
# new
    get new_note_image_url(@note)
    assert_response :success
# create
    assert_difference('Image.count') do
      post "/notes/#{@note.id}/images", params: {image: {
        name: 'new_name',
        image: fixture_file_upload("test/jogasaki.jpg", 'image/jpeg', true)
      } }
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "owner should get edit and update image" do
    login
# edit
    get edit_note_image_url(@note, @image)
    assert_response :success
# update
    update_image = IO.binread("test/jogasaki.jpg",nil)
    patch "/notes/#{@note.id}/images/#{@image.id}", params: {image: {
        name: 'update_name',
        image: fixture_file_upload("test/jogasaki.jpg", 'image/jpeg', true)
      } }
    saved_image = Image.find(@image.id).image
    assert_equal saved_image, update_image
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "owner should destroy note" do
    login
    assert_difference('Image.count', -1) do
      delete "/notes/#{@note.id}/images/#{@image.id}"
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Note was successfully destroyed.', flash[:success]
  end

  private
    def login
      post "/logins/create", params: {email: @user.email, password: 'aabbccddeeffgg'}
      assert_response :redirect
      follow_redirect!
      assert_response :success
    end
end
