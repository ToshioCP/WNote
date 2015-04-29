require 'test_helper'

class SectionsControllerTest < ActionController::TestCase
  setup do
    @section = sections(:one)
    @article = @section.article
    @user = users(:toshiocp)
# @another_user is not the owner of @note.
# It is used in the test for the read/write permission and r/w_public flag.
    @another_user = users(:foobar)
# Some situations make the redirection to :back.
# For example GUEST can't access some action and it make the redirection to :back.
# Testing such redirection needs HTTP_REFERER.
    @request.headers["HTTP_REFERER"] = root_url
  end

  test "should get new" do
    get :new, {article_id: @article.id}, {current_user_id: @user.id}
    assert_response :success
    assert_select 'nav' do
      assert_select 'a', 'Article'
    end
    assert_select 'form' do
      assert_select 'select.form-control' do
        assert_select 'option',articles(:wnote).title
        assert_select 'option',articles(:rails_howto).title
      end
      assert_select 'input.form-control'
      assert_select 'input.btn'
      assert_select 'input.btn-primary'
    end
  end

  test "guest shouldn't get new" do
    get :new, {article_id: @article.id}
    assert_redirected_to :back
  end

  test "should get create" do
    assert_difference('Section.count') do
      post :create, {section: {article_id: @article.id, heading: 'New Heading'}}, {current_user_id: @user.id}
    end
    section = Section.find(assigns(:section).id)
    assert_redirected_to section_path(section)
    assert_equal 'Section was successfully created.', flash[:success]
    assert_equal @article, section.article
    assert_equal 'New Heading', section.heading
  end

  test "guest shouldn't get create" do
    assert_no_difference('Section.count') do
      post :create, {section: {article_id: @article.id, heading: 'New Heading'}}
    end
  end

  test "should show section" do
    get :show, {id: @section}, {current_user_id: @user.id}
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      assert_select 'a', 'Article'
      assert_select 'a', 'New Section'
      assert_select 'a', 'Edit Section'
      assert_select 'a', 'Destroy Section'
      assert_select 'a', 'New Note'
    end
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'h2', @section.heading
      assert_select 'tr' do
        assert_select 'td', 'Show'
        assert_select 'td', 'Install_rbenv'
        assert_select 'td', 'Visit rbeny site and download it.'
      end
    end
  end

  test "Only the owner can read section when r_public is off" do
    @article.update(r_public: 0) # off
    get :show, {id: @section}, {current_user_id: @another_user.id}
    assert_redirected_to :back
    get :show, {id: @section}, {current_user_id: nil} #GUEST
    assert_redirected_to :back
    @article.update(r_public: 1) # on
    get :show, {id: @section}, {current_user_id: @another_user.id}
    assert_response :success
    get :show, {id: @section}, {current_user_id: nil} #GUEST
    assert_response :success
  end

  test "should get edit" do
    get :edit, {id: @section}, {current_user_id: @user.id}
    assert_response :success
    assert_select 'nav' do
      assert_select 'a', 'Article'
    end
    assert_select 'div.wnote-main' do
      assert_select 'select.form-control' do
        assert_select 'option',articles(:wnote).title
        assert_select 'option',articles(:rails_howto).title
      end
      assert_select 'input.form-control'
      assert_select 'ul' do
        assert_select 'li', 'Install_rbenv'
        assert_select 'li', 'Install_ruby'
        assert_select 'li', 'Install_rails'
      end
      assert_select 'input.btn'
      assert_select 'input.btn-primary'
      assert_select 'input#edit_section_submit'
    end
  end

  test "incorrect user shouldn't get edit" do
    @article.update(w_public: 0) # off
    get :edit, {id: @section} , {current_user_id: @another_user.id}
    assert_response :redirect, "Incorrect user saw editing page." 
    @article.update(w_public: 1) # on
    get :edit, {id: @section} , {current_user_id: @another_user.id}
    assert_response :success, "The other user couldn't see editing page, though w_public was on."
  end

  test "should get update" do
    article_id = articles(:rails_howto).id
    note_order = "#{notes(:install_ruby)},#{notes(:install_rbenv)},#{notes(:install_rails)}" # exchange 1,2
    patch :update, {id: @section, section: {article_id: article_id, heading: 'Updated Heading', note_order: note_order}},
          {current_user_id: @user.id}
    assert_redirected_to section_path(assigns(:section))
    assert_equal 'Section was successfully updated.', flash[:success]
    section = Section.find(@section.id)
    assert_equal article_id, section.article_id
    assert_equal 'Updated Heading', section.heading
    assert_equal note_order, section.note_order
  end

  test "incorrect user shouldn't update section" do
    @article.update(w_public: 0) # off
    patch :update, {id: @section, section: {heading: 'Updated Heading'}}, {current_user_id: @another_user.id}
    section = Section.find(@section.id) # reload
    assert_not_equal 'Updated Heading', section.heading, "Heading was updated."
    @article.update(w_public: 1) # on
    patch :update, {id: @section, section: {heading: 'Updated Heading'}}, {current_user_id: @another_user.id}
    section = Section.find(@section.id) # reload
    assert_equal 'Updated Heading', section.heading, "Heading wasn't updated."
  end

  test "should destroy article" do
    article = @section.article
    assert_difference('Section.count', -1) do
      delete :destroy, {id: @section}, {current_user_id: @user.id}
    end
    assert_redirected_to article_path(article)
    assert_equal 'Section was successfully destroyed.', flash[:success]
  end

  test "incorrect user shouldn't destroy section" do
    @article.update(w_public: 1) # even if w_public is on
    assert_no_difference('Section.count') do
      delete :destroy, {id: @section}, {current_user_id: @another_user.id}
    end
  end

end
