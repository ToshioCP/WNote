require 'test_helper'

class SectionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @section = sections(:one)
    @article = @section.article
    @user = users(:toshiocp)
# Some situations make the redirection to :back.
# For example GUEST can't access some action and it make the redirection to :back.
# Testing such redirection needs HTTP_REFERER.
#    @request.headers["HTTP_REFERER"] = root_url
  end

  test "logged in user should get new" do
    login
    get new_article_section_path(@article)
    assert_response :success
    assert_select 'form' do
      assert_select 'select.form-control' do
        assert_select 'option',articles(:wnote).title
#        assert_select 'option',articles(:rails_howto).title  他のユーザのアーティクルはここには出てこない
      end
      assert_select 'input.form-control'
      assert_select 'input.btn'
      assert_select 'input.btn-primary'
    end
  end

  test "guest shouldn't get new" do
    get new_article_section_path(@article)
    assert_response :redirect
    follow_redirect!
    assert_response :success
  end

  test "logged in user should get create" do
    login
    assert_difference('Section.count') do
      post sections_path, params: {section: {article_id: @article.id, heading: 'New Heading'}}
    end
    section = Section.last
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Section was successfully created.', flash[:success]
    assert_equal @article, section.article
    assert_equal 'New Heading', section.heading
  end

  test "guest shouldn't get create" do
    assert_no_difference('Section.count') do
      post sections_path, params: {section: {article_id: @article.id, heading: 'New Heading'}}
    end
  end

  test "logged in user should show section" do
    login
    get section_path(@section)
    assert_select 'nav' do
#      assert_select 'a.navbar-brand', 'WNote'
      # assert_select 'a', 'List_Articles'
      assert_select 'a', 'New Section'
      assert_select 'a', 'Edit Section'
      assert_select 'a', 'Delete Section'
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
# Guest
    @article.update(r_public: 0) # off
    get section_path(@section)
    assert_response :redirect
    follow_redirect!
    assert_response :success
    @article.update(r_public: 1) # on
    get section_path(@section)
    assert_response :success
# Another user
    login_another_user
    @article.update(r_public: 0) # off
    get section_path(@section)
    assert_response :redirect
    follow_redirect!
    assert_response :success
    @article.update(r_public: 1) # on
    get section_path(@section)
    assert_response :success
  end

  test "logged in user should get edit" do
    login
    get edit_section_path(@section)
    assert_response :success
    assert_select 'div.wnote-main' do
      assert_select 'select.form-control' do
        assert_select 'option',articles(:wnote).title
#        assert_select 'option',articles(:rails_howto).title  他のユーザのアーティクルはここには出てこない
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
    login_another_user
    @article.update(w_public: 0) # off
    get edit_section_path(@section)
    assert_response :redirect, "Incorrect user saw editing page."
    @article.update(w_public: 1) # on
    get edit_section_path(@section)
    assert_response :success, "The other user couldn't see editing page, though w_public was on."
  end

  test "logged in user should get update" do
    login
    article_id = articles(:lua).id
    note_order = "#{notes(:install_ruby).id},#{notes(:install_rbenv).id},#{notes(:install_rails).id}" # exchange 1,2
    patch section_path(@section), params: {section: {article_id: article_id, heading: 'Updated Heading', note_order: note_order}}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Section was successfully updated.', flash[:success]
    section = Section.find(@section.id)
    assert_equal article_id, section.article_id
    assert_equal 'Updated Heading', section.heading
    assert_equal note_order, section.note_order
  end

  test "incorrect user shouldn't update section" do
    login_another_user
    @article.update(w_public: 0) # off
    patch "/sections/#{@section.id}", params: {section: {heading: 'Updated Heading'}}
    section = Section.find(@section.id) # reload
    assert_not_equal 'Updated Heading', section.heading, "Heading was updated."
    @article.update(w_public: 1) # on
    patch "/sections/#{@section.id}", params: {section: {heading: 'Updated Heading'}}
    section = Section.find(@section.id) # reload
    assert_equal 'Updated Heading', section.heading, "Heading wasn't updated."
  end

  test "logged in user should destroy article" do
    login
    article = @section.article
    assert_difference('Section.count', -1) do
      delete "/sections/#{@section.id}"
    end
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Section was successfully destroyed.', flash[:success]
  end

  test "incorrect user shouldn't destroy section" do
    login_another_user
    @article.update(w_public: 0)
    assert_no_difference('Section.count') do
      delete "/sections/#{@section.id}"
    end
  end

end
