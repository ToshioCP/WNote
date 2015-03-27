require 'test_helper'

class SectionsControllerTest < ActionController::TestCase
  setup do
    @section = sections(:one)
    @section.article= articles(:one)
    @section.save
  end

  test "should get new" do
    get :new, article_id: @section.article.id
    assert_response :success
  end

  test "should get create" do
    assert_difference('Section.count') do
      post :create, article_id: @section.article.id, section: { heading: @section.heading }
    end
    assert_redirected_to section_path(assigns(:section))
    assert_equal 'Section was successfully created.', flash[:success]
  end

  test "should show section" do
    get :show, id: @section
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'Article'
      assert_select 'a', 'New Section'
      assert_select 'a', 'Edit Section'
      assert_select 'a', 'Destroy Section'
      assert_select 'a', 'New Note'
    end
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @section
    assert_response :success
  end

  test "should get update" do
    patch :update, id: @section, section: { heading: "changed" }
    assert_redirected_to section_path(assigns(:section))
    assert_equal 'Section was successfully updated.', flash[:success]
  end
end
